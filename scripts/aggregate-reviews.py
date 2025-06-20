#!/usr/bin/env python3

import json
import sys
import os
from pathlib import Path

def find_config_file():
    """Find the config.json file by walking up the directory tree"""
    current = Path(__file__).resolve().parent
    while current != current.parent:
        config_path = current / "config.json"
        if config_path.exists():
            return config_path
        current = current.parent
    return None

def load_config():
    """Load configuration from config.json"""
    config_path = find_config_file()
    if config_path:
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Warning: Failed to load config.json: {e}")
    return {}

def load_review(filepath):
    """Load a review JSON file, return empty dict if failed"""
    try:
        with open(filepath, 'r') as f:
            content = f.read().strip()
            if not content:
                return {"status": "error", "issues": []}
            
            # First try to parse as JSON
            try:
                data = json.loads(content)
                # Check if this is Claude's wrapper format
                if isinstance(data, dict) and 'result' in data and isinstance(data['result'], str):
                    # Extract the actual review JSON from Claude's result field
                    result = data['result']
                    # Remove markdown code blocks if present
                    result = result.replace('```json', '').replace('```', '').strip()
                    return json.loads(result)
                else:
                    return data
            except json.JSONDecodeError:
                # Try to extract JSON from the content (claude might add extra text)
                import re
                json_match = re.search(r'\{.*\}', content, re.DOTALL)
                if json_match:
                    return json.loads(json_match.group())
                    
        return {"status": "error", "issues": []}
    except Exception as e:
        print(f"Warning: Failed to load {filepath}: {e}")
        return {"status": "error", "issues": []}

def aggregate_reviews(architect_path, security_path, testing_path, documentation_path=None, devops_path=None, ux_path=None):
    """Aggregate all review results and determine overall status"""
    
    reviews = {
        "architect": load_review(architect_path),
        "security": load_review(security_path),
        "testing": load_review(testing_path)
    }
    
    # Add optional review roles if provided
    if documentation_path and os.path.exists(documentation_path):
        reviews["documentation"] = load_review(documentation_path)
    if devops_path and os.path.exists(devops_path):
        reviews["devops"] = load_review(devops_path)
    if ux_path and os.path.exists(ux_path):
        reviews["ux"] = load_review(ux_path)
    
    # Determine overall status
    has_critical = False
    has_high = False
    all_issues = []
    
    for role, review in reviews.items():
        if review.get("status") == "fail":
            has_critical = True
        
        for issue in review.get("issues", []):
            issue["reviewer"] = role
            all_issues.append(issue)
            
            if issue.get("severity") == "critical":
                has_critical = True
            elif issue.get("severity") == "high":
                has_high = True
    
    # Print results
    if not all_issues:
        print("✅ No issues found in AI reviews")
        return 0
    
    print(f"\n📊 AI Review Summary: {len(all_issues)} issues found\n")
    
    # Group by severity
    by_severity = {"critical": [], "high": [], "medium": [], "low": []}
    for issue in all_issues:
        severity = issue.get("severity", "medium")
        by_severity[severity].append(issue)
    
    # Print issues by severity
    for severity in ["critical", "high", "medium", "low"]:
        issues = by_severity[severity]
        if issues:
            emoji = {"critical": "🚨", "high": "❗", "medium": "⚠️ ", "low": "💡"}[severity]
            print(f"{emoji} {severity.upper()} ({len(issues)} issues):")
            for issue in issues:
                print(f"  [{issue['reviewer']}] {issue['file']}:{issue.get('line', '?')}")
                print(f"    {issue['issue']}")
                if issue.get('suggestion'):
                    print(f"    → {issue['suggestion']}")
            print()
    
    # Return non-zero if critical or high issues
    if has_critical:
        print("❌ Critical issues must be fixed before committing")
        return 1
    elif has_high:
        print("⚠️  High priority issues should be addressed")
        print("Use 'git commit --no-verify' to bypass if necessary")
        return 1
    else:
        print("✅ No blocking issues found")
        return 0

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: aggregate-reviews.py <architect.json> <security.json> <testing.json> [documentation.json] [devops.json] [ux.json]")
        sys.exit(1)
    
    # Required parameters
    architect_path = sys.argv[1]
    security_path = sys.argv[2]
    testing_path = sys.argv[3]
    
    # Optional parameters
    documentation_path = sys.argv[4] if len(sys.argv) > 4 else None
    devops_path = sys.argv[5] if len(sys.argv) > 5 else None
    ux_path = sys.argv[6] if len(sys.argv) > 6 else None
    
    sys.exit(aggregate_reviews(architect_path, security_path, testing_path, 
                              documentation_path, devops_path, ux_path))
