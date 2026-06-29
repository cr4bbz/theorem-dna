from __future__ import annotations

from theorem_dna.report import render_verification_html, render_verification_markdown


def sample_report() -> dict:
    return {
        "schema_version": "0.1.0",
        "generated_at": "2026-06-29T19:36:41Z",
        "repository": "C:/repo",
        "commit": "abc123",
        "mode": "full",
        "overall": "PASS",
        "results": [
            {
                "name": "Lean",
                "status": "PASS",
                "duration_seconds": 1.25,
                "detail": "Build completed successfully.",
            }
        ],
    }


def test_markdown_report_contains_summary_table():
    markdown = render_verification_markdown(sample_report())

    assert "Overall: `PASS`" in markdown
    assert "| Lean | PASS | 1.2s |" in markdown


def test_html_report_escapes_details():
    report = sample_report()
    report["results"][0]["detail"] = "<script>alert('nope')</script>"

    html = render_verification_html(report)

    assert "Overall result: PASS" in html
    assert "<script>" not in html
    assert "&lt;script&gt;" in html
