import unittest
from ryu_perfhook_port import restore_min_first


class RestoreTests(unittest.TestCase):
    def fixture(self, method, maximum, minimum, high, low):
        return (f'.method private {method}()Z\n    .locals 3\n'
                f'    iget-object v1, p1, LPolicy;->{maximum}:Ljava/lang/String;\n'
                f'    iget-object v2, p1, LPolicy;->{high}:Ljava/lang/String;\n'
                '    invoke-direct {p0, v1, v2}, LHook;->writeFrequencyAndVerify(Ljava/lang/String;Ljava/lang/String;)Z\n'
                '    move-result v0\n    if-eqz v0, :failed\n'
                f'    iget-object v1, p1, LPolicy;->{minimum}:Ljava/lang/String;\n'
                f'    iget-object v2, p1, LPolicy;->{low}:Ljava/lang/String;\n'
                '    invoke-direct {p0, v1, v2}, LHook;->writeFrequencyAndVerify(Ljava/lang/String;Ljava/lang/String;)Z\n'
                '    move-result v0\n:failed\n    return v0\n.end method\n')

    def test_restore_lowers_min_before_max_and_preserves_failure_check(self):
        for args in [('restoreCpuFrequencyRange', 'scalingMax', 'scalingMin', 'cachedInfoMax', 'cachedInfoMin'),
                     ('restoreGpuDefault', 'maxFreq', 'minFreq', 'availableMax', 'availableMin')]:
            original = self.fixture(*args)
            result = restore_min_first(original)
            self.assertLess(result.index('->' + args[2] + ':'), result.index('->' + args[1] + ':'))
            self.assertIn('if-eqz v0, :failed', result)
            self.assertEqual(restore_min_first(result), result)
            boost = original.replace(args[0], 'enforceMax')
            self.assertEqual(restore_min_first(boost), boost)

    def test_unknown_layout_refused(self):
        text = self.fixture('restoreGpuDefault', 'maxFreq', 'missing', 'availableMax', 'availableMin')
        with self.assertRaisesRegex(ValueError, 'layout'):
            restore_min_first(text)
