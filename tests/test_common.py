"""Tests for rules.common dataclasses."""

import pytest

from rules.common import Finding, RuleResult, Severity


class TestSeverity:
    def test_values(self):
        assert Severity.BLOCKER == "blocker"
        assert Severity.INFO == "info"

    def test_is_str_subclass(self):
        assert isinstance(Severity.BLOCKER, str)


class TestFinding:
    def test_fields(self):
        f = Finding(severity="blocker", file="foo.go", line=10, image="quay.io/x:latest", message="bad tag")
        assert f.severity == "blocker"
        assert f.file == "foo.go"
        assert f.line == 10
        assert f.image == "quay.io/x:latest"
        assert f.message == "bad tag"

    def test_severity_coerced_to_enum(self):
        f = Finding("blocker", "f.go", 1, "", "m")
        assert f.severity == Severity.BLOCKER

    def test_invalid_severity_raises(self):
        with pytest.raises(ValueError, match="Invalid severity"):
            Finding("warning", "f.go", 1, "", "m")

    def test_equality(self):
        a = Finding("info", "a.py", 1, "", "msg")
        b = Finding("info", "a.py", 1, "", "msg")
        assert a == b

    def test_inequality(self):
        a = Finding("blocker", "a.py", 1, "", "msg")
        b = Finding("info", "a.py", 1, "", "msg")
        assert a != b

    def test_severity_string_comparison(self):
        f = Finding("blocker", "f.go", 1, "", "m")
        assert f.severity == "blocker"
        assert f.severity != "info"


class TestRuleResult:
    def test_defaults(self):
        r = RuleResult(rule="test-rule")
        assert r.rule == "test-rule"
        assert r.passed is True
        assert r.findings == []
        assert r.files_checked == []

    def test_mutable_default_isolation(self):
        r1 = RuleResult(rule="a")
        r2 = RuleResult(rule="b")
        r1.findings.append(Finding("info", "", 0, "", "x"))
        assert r2.findings == []

    def test_files_checked_isolation(self):
        r1 = RuleResult(rule="a")
        r2 = RuleResult(rule="b")
        r1.files_checked.append("foo.go")
        assert r2.files_checked == []

    def test_passed_override(self):
        r = RuleResult(rule="x", passed=False)
        assert r.passed is False

    def test_findings_provided(self):
        findings = [Finding("blocker", "f.go", 5, "img", "m")]
        r = RuleResult(rule="x", passed=False, findings=findings)
        assert len(r.findings) == 1
        assert r.findings[0].severity == "blocker"
