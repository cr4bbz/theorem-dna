from __future__ import annotations

from datetime import datetime
from html import escape
from pathlib import Path
from typing import Any


def _format_duration(seconds: float | int | None) -> str:
    if seconds is None:
        return "-"
    return f"{float(seconds):.1f}s"


def _trim_detail(detail: str | None, limit: int = 1200) -> str:
    if not detail:
        return ""
    detail = detail.strip()
    if len(detail) <= limit:
        return detail
    return detail[:limit].rstrip() + "\n…"


def render_verification_markdown(report: dict[str, Any]) -> str:
    rows = []
    for result in report.get("results", []):
        rows.append(
            "| {name} | {status} | {duration} |".format(
                name=str(result.get("name", "")),
                status=str(result.get("status", "")),
                duration=_format_duration(result.get("duration_seconds")),
            )
        )

    return "\n".join(
        [
            "# Theorem DNA Verification Report",
            "",
            f"- Overall: `{report.get('overall', 'UNKNOWN')}`",
            f"- Mode: `{report.get('mode', '-')}`",
            f"- Commit: `{report.get('commit', '-')}`",
            f"- Generated at: `{report.get('generated_at', '-')}`",
            "",
            "| Step | Status | Duration |",
            "| --- | --- | ---: |",
            *rows,
            "",
        ]
    )


def render_verification_html(report: dict[str, Any]) -> str:
    overall = str(report.get("overall", "UNKNOWN"))
    generated_at = str(report.get("generated_at", "-"))
    try:
        generated_label = datetime.fromisoformat(
            generated_at.replace("Z", "+00:00")
        ).strftime("%Y-%m-%d %H:%M:%S UTC")
    except ValueError:
        generated_label = generated_at

    cards = []
    for result in report.get("results", []):
        status = str(result.get("status", "UNKNOWN"))
        name = escape(str(result.get("name", "")))
        duration = escape(_format_duration(result.get("duration_seconds")))
        detail = escape(_trim_detail(result.get("detail")))
        status_class = "pass" if status == "PASS" else "fail"
        detail_block = (
            f"<pre>{detail}</pre>"
            if detail
            else "<p class=\"muted\">No additional output.</p>"
        )
        cards.append(
            f"""
      <section class="card {status_class}">
        <div class="card-title">
          <h2>{name}</h2>
          <span>{escape(status)}</span>
        </div>
        <p class="duration">{duration}</p>
        {detail_block}
      </section>"""
        )

    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Theorem DNA Verification Report</title>
  <style>
    :root {{
      color-scheme: light dark;
      --bg: #0f172a;
      --panel: #111827;
      --text: #e5e7eb;
      --muted: #9ca3af;
      --pass: #22c55e;
      --fail: #ef4444;
      --border: #334155;
    }}
    body {{
      margin: 0;
      font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: radial-gradient(circle at top left, #1e293b, var(--bg));
      color: var(--text);
    }}
    main {{
      max-width: 1100px;
      margin: 0 auto;
      padding: 40px 24px;
    }}
    header {{
      border: 1px solid var(--border);
      background: rgb(17 24 39 / 0.82);
      border-radius: 20px;
      padding: 28px;
      box-shadow: 0 24px 80px rgb(0 0 0 / 0.25);
    }}
    h1 {{
      margin: 0 0 12px;
      font-size: clamp(2rem, 5vw, 4rem);
      letter-spacing: -0.05em;
    }}
    .overall {{
      display: inline-flex;
      align-items: center;
      gap: 10px;
      padding: 8px 14px;
      border-radius: 999px;
      font-weight: 800;
      background: {("#14532d" if overall == "PASS" else "#7f1d1d")};
      color: white;
    }}
    .meta {{
      margin-top: 18px;
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 10px;
      color: var(--muted);
    }}
    .grid {{
      margin-top: 24px;
      display: grid;
      gap: 16px;
    }}
    .card {{
      border: 1px solid var(--border);
      border-left-width: 6px;
      border-radius: 16px;
      background: rgb(17 24 39 / 0.76);
      padding: 18px;
    }}
    .card.pass {{ border-left-color: var(--pass); }}
    .card.fail {{ border-left-color: var(--fail); }}
    .card-title {{
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }}
    .card h2 {{
      margin: 0;
      font-size: 1.1rem;
    }}
    .card-title span {{
      font-weight: 800;
    }}
    .duration, .muted {{
      color: var(--muted);
    }}
    pre {{
      overflow-x: auto;
      white-space: pre-wrap;
      border-radius: 12px;
      border: 1px solid var(--border);
      padding: 12px;
      background: rgb(15 23 42 / 0.72);
      color: #d1d5db;
      max-height: 280px;
    }}
  </style>
</head>
<body>
  <main>
    <header>
      <h1>Theorem DNA Verification</h1>
      <div class="overall">Overall result: {escape(overall)}</div>
      <div class="meta">
        <div>Mode: <code>{escape(str(report.get("mode", "-")))}</code></div>
        <div>Commit: <code>{escape(str(report.get("commit", "-")))}</code></div>
        <div>Generated: <code>{escape(generated_label)}</code></div>
      </div>
    </header>
    <div class="grid">
      {"".join(cards)}
    </div>
  </main>
</body>
</html>
"""


def write_verification_reports(report: dict[str, Any], output_dir: Path) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    markdown_path = output_dir / "last-report.md"
    html_path = output_dir / "last-report.html"
    markdown_path.write_text(
        render_verification_markdown(report), encoding="utf-8", newline="\n"
    )
    html_path.write_text(
        render_verification_html(report), encoding="utf-8", newline="\n"
    )
    return markdown_path, html_path
