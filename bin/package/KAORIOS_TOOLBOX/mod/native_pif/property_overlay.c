// Process-local PIF property view for Android's read-only property areas.
// This implementation uses the stable prop_info layout published by Bionic.
// It does not change the device's shared property files or install a linker hook.

#define _GNU_SOURCE
#include <android/log.h>
#include <jni.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/system_properties.h>
#include <unistd.h>

#define TAG "KaoriosNativePIF"
#define MAX_RULES 16
#define MAX_PAGES 32
#define NAME_CAP 128
#define VALUE_CAP PROP_VALUE_MAX
#define LONG_FLAG (1u << 16)

typedef struct {
  const prop_info* pi;
  char name[NAME_CAP];
  char before[VALUE_CAP];
  char after[VALUE_CAP];
  uint32_t serial;
  bool changed;
} Rule;

typedef struct {
  uintptr_t address;
  unsigned char* snapshot;
} Page;

typedef struct {
  char* output;
  size_t capacity;
} ReadCookie;

static const char* const allowed_names[] = {
    "ro.build.fingerprint", "ro.build.id", "ro.product.device", "ro.product.name",
    "ro.product.brand", "ro.product.model", "ro.build.version.security_patch",
    "ro.product.first_api_level",
};
static _Atomic int install_state;

static void read_property(void* cookie, const char* name, const char* value, uint32_t serial) {
  (void)name;
  (void)serial;
  ReadCookie* read = (ReadCookie*)cookie;
  size_t size = strnlen(value, read->capacity);
  if (size >= read->capacity) return;
  memcpy(read->output, value, size + 1);
}

static bool permitted_name(const char* name) {
  for (size_t i = 0; i < sizeof(allowed_names) / sizeof(allowed_names[0]); ++i) {
    if (strcmp(name, allowed_names[i]) == 0) return true;
  }
  return false;
}

static bool property_mapping_contains(uintptr_t address) {
  FILE* maps = fopen("/proc/self/maps", "re");
  if (!maps) return false;
  char* line = NULL;
  size_t capacity = 0;
  bool found = false;
  while (getline(&line, &capacity, maps) > 0) {
    unsigned long start = 0, end = 0;
    char perms[5] = {0};
    if (sscanf(line, "%lx-%lx %4s", &start, &end, perms) != 3) continue;
    if (address >= start && address < end &&
        strstr(line, "/dev/__properties__/") != NULL && perms[0] == 'r') {
      found = true;
      break;
    }
  }
  free(line);
  fclose(maps);
  return found;
}

static bool add_page(Page* pages, size_t* count, uintptr_t address, size_t page_size) {
  address &= ~(uintptr_t)(page_size - 1);
  for (size_t i = 0; i < *count; ++i) {
    if (pages[i].address == address) return true;
  }
  if (*count >= MAX_PAGES || !property_mapping_contains(address)) return false;
  Page* page = &pages[*count];
  page->snapshot = malloc(page_size);
  if (!page->snapshot) return false;
  page->address = address;
  memcpy(page->snapshot, (const void*)address, page_size);
  ++*count;
  return true;
}

static bool private_page(const Page* page, size_t page_size) {
  void* mapped = mmap((void*)page->address, page_size, PROT_READ | PROT_WRITE,
                      MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
  if (mapped != (void*)page->address) return false;
  memcpy(mapped, page->snapshot, page_size);
  return true;
}

static void restore_rules(Rule* rules, size_t count) {
  for (size_t i = 0; i < count; ++i) {
    if (!rules[i].changed) continue;
    char* location = (char*)rules[i].pi;
    memcpy(location + sizeof(uint32_t), rules[i].before, strlen(rules[i].before) + 1);
    atomic_store_explicit((_Atomic uint32_t*)location, rules[i].serial, memory_order_release);
  }
}

static bool install_rules(Rule* rules, size_t count) {
  Page pages[MAX_PAGES] = {0};
  size_t page_count = 0;
  size_t page_size = (size_t)sysconf(_SC_PAGESIZE);
  bool ok = page_size >= 4096 && (page_size & (page_size - 1)) == 0;

  for (size_t i = 0; ok && i < count; ++i) {
    if (!rules[i].changed) continue;
    uintptr_t first = (uintptr_t)rules[i].pi;
    uintptr_t last = first + sizeof(uint32_t) + strlen(rules[i].after);
    for (uintptr_t page = first & ~(uintptr_t)(page_size - 1);
         page <= last; page += page_size) {
      if (!add_page(pages, &page_count, page, page_size)) {
        ok = false;
        break;
      }
    }
  }

  for (size_t i = 0; ok && i < page_count; ++i) {
    if (!private_page(&pages[i], page_size)) ok = false;
  }

  if (ok) {
    for (size_t i = 0; i < count; ++i) {
      if (!rules[i].changed) continue;
      char* location = (char*)rules[i].pi;
      size_t length = strlen(rules[i].after);
      memcpy(location + sizeof(uint32_t), rules[i].after, length + 1);
      uint32_t serial = (rules[i].serial & 0x00ffffffu) | ((uint32_t)length << 24);
      atomic_store_explicit((_Atomic uint32_t*)location, serial, memory_order_release);
    }

    for (size_t i = 0; i < count; ++i) {
      if (!rules[i].changed) continue;
      char actual[VALUE_CAP] = {0};
      ReadCookie read = {actual, sizeof(actual)};
      __system_property_read_callback(rules[i].pi, read_property, &read);
      if (strcmp(actual, rules[i].after) != 0) {
        ok = false;
        break;
      }
    }
    if (!ok) restore_rules(rules, count);
  }

  bool protected = true;
  for (size_t i = 0; i < page_count; ++i) {
    // Keep the process-local property view read-only after initialization.
    if (pages[i].snapshot &&
        mprotect((void*)pages[i].address, page_size, PROT_READ) != 0) protected = false;
  }
  if (ok && !protected) {
    for (size_t i = 0; i < page_count; ++i) {
      if (pages[i].snapshot) {
        mprotect((void*)pages[i].address, page_size, PROT_READ | PROT_WRITE);
      }
    }
    restore_rules(rules, count);
    for (size_t i = 0; i < page_count; ++i) {
      if (pages[i].snapshot) mprotect((void*)pages[i].address, page_size, PROT_READ);
    }
    ok = false;
  }
  for (size_t i = 0; i < page_count; ++i) {
    free(pages[i].snapshot);
  }
  return ok;
}

JNIEXPORT jboolean JNICALL
Java_android_security_ntmanager_PifNative_nativeInstall(JNIEnv* env, jclass type,
                                                          jobjectArray names, jobjectArray values) {
  (void)type;
  if (atomic_load_explicit(&install_state, memory_order_acquire) == 2) return JNI_TRUE;
  if (!names || !values) return JNI_FALSE;
  jsize count = (*env)->GetArrayLength(env, names);
  if (count <= 0 || count > MAX_RULES || (*env)->GetArrayLength(env, values) != count) return JNI_FALSE;

  Rule rules[MAX_RULES] = {0};
  size_t selected = 0;
  bool fingerprint = false;
  for (jsize i = 0; i < count; ++i) {
    jstring jname = (jstring)(*env)->GetObjectArrayElement(env, names, i);
    jstring jvalue = (jstring)(*env)->GetObjectArrayElement(env, values, i);
    if (!jname || !jvalue) {
      if (jname) (*env)->DeleteLocalRef(env, jname);
      if (jvalue) (*env)->DeleteLocalRef(env, jvalue);
      return JNI_FALSE;
    }
    const char* name = (*env)->GetStringUTFChars(env, jname, NULL);
    const char* value = (*env)->GetStringUTFChars(env, jvalue, NULL);
    if (!name || !value) {
      if (name) (*env)->ReleaseStringUTFChars(env, jname, name);
      if (value) (*env)->ReleaseStringUTFChars(env, jvalue, value);
      (*env)->DeleteLocalRef(env, jname);
      (*env)->DeleteLocalRef(env, jvalue);
      return JNI_FALSE;
    }
    bool valid = permitted_name(name) && strlen(name) < NAME_CAP &&
                 strlen(value) < VALUE_CAP && strncmp(name, "ro.", 3) == 0;
    if (valid) {
      Rule* rule = &rules[selected];
      snprintf(rule->name, sizeof(rule->name), "%s", name);
      snprintf(rule->after, sizeof(rule->after), "%s", value);
      rule->pi = __system_property_find(rule->name);
      if (rule->pi) {
        const char* layout = (const char*)rule->pi;
        rule->serial = atomic_load_explicit((const _Atomic uint32_t*)layout, memory_order_acquire);
        valid = (rule->serial & LONG_FLAG) == 0 &&
                strcmp(layout + sizeof(uint32_t) + VALUE_CAP, rule->name) == 0;
        if (valid) {
          ReadCookie read = {rule->before, sizeof(rule->before)};
          __system_property_read_callback(rule->pi, read_property, &read);
          rule->changed = strcmp(rule->before, rule->after) != 0;
          if (strcmp(rule->name, "ro.build.fingerprint") == 0) fingerprint = true;
          ++selected;
        }
      }
    }
    (*env)->ReleaseStringUTFChars(env, jname, name);
    (*env)->ReleaseStringUTFChars(env, jvalue, value);
    (*env)->DeleteLocalRef(env, jname);
    (*env)->DeleteLocalRef(env, jvalue);
    if (!valid) {
      __android_log_print(ANDROID_LOG_ERROR, TAG, "Unsupported property layout for rule %d", i);
      return JNI_FALSE;
    }
  }

  if (!fingerprint || selected == 0) return JNI_FALSE;
  int expected = 0;
  if (!atomic_compare_exchange_strong_explicit(&install_state, &expected, 1,
                                                memory_order_acq_rel, memory_order_acquire)) {
    return expected == 2 ? JNI_TRUE : JNI_FALSE;
  }
  bool ok = install_rules(rules, selected);
  atomic_store_explicit(&install_state, ok ? 2 : 0, memory_order_release);
  __android_log_print(ok ? ANDROID_LOG_INFO : ANDROID_LOG_ERROR, TAG,
                      "Process-local property view %s (%zu rules)", ok ? "verified" : "failed", selected);
  return ok ? JNI_TRUE : JNI_FALSE;
}
