#!/usr/bin/env python3
"""
Script to analyze hymns.json and generate a markdown report of hymns missing
author, composer, or style information, and add line breaks before "Refrain".
"""

import json
import os
from typing import Any, Dict, List


def load_hymns(file_path: str) -> List[Dict[str, Any]]:
    """Load hymns from JSON file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def add_line_breaks_before_refrain(lyrics: str) -> str:
    """Add line breaks before 'Refrain' in lyrics."""
    return lyrics.replace('\nRefrain', '\n\nRefrain')

def analyze_hymns(hymns: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
    """Analyze hymns and categorize missing information."""
    missing_author = []
    missing_composer = []
    missing_style = []
    
    for hymn in hymns:
        hymn_info = {
            'number': hymn.get('number', 'Unknown'),
            'title': hymn.get('title', 'Unknown'),
            'author': hymn.get('author', ''),
            'composer': hymn.get('composer', ''),
            'style': hymn.get('style', '')
        }
        
        # Check for missing author
        if not hymn_info['author'] or hymn_info['author'].strip() == '':
            missing_author.append(hymn_info)
        
        # Check for missing composer
        if not hymn_info['composer'] or hymn_info['composer'].strip() == '':
            missing_composer.append(hymn_info)
        
        # Check for missing style
        if not hymn_info['style'] or hymn_info['style'].strip() == '':
            missing_style.append(hymn_info)
    
    return {
        'missing_author': missing_author,
        'missing_composer': missing_composer,
        'missing_style': missing_style
    }


def generate_markdown_report(analysis: Dict[str, List[Dict[str, Any]]]) -> str:
    """Generate markdown report."""
    report = "# Hymns Analysis Report\n\n"
    
    # Missing Author section
    report += "## Hymns Missing Author\n\n"
    if analysis['missing_author']:
        report += f"**Total: {len(analysis['missing_author'])} hymns**\n\n"
        for hymn in analysis['missing_author']:
            report += f"- **#{hymn['number']}**: {hymn['title']}\n"
    else:
        report += "No hymns missing author information.\n"
    
    report += "\n---\n\n"
    
    # Missing Composer section
    report += "## Hymns Missing Composer\n\n"
    if analysis['missing_composer']:
        report += f"**Total: {len(analysis['missing_composer'])} hymns**\n\n"
        for hymn in analysis['missing_composer']:
            report += f"- **#{hymn['number']}**: {hymn['title']}\n"
    else:
        report += "No hymns missing composer information.\n"
    
    report += "\n---\n\n"
    
    # Missing Style section
    report += "## Hymns Missing Style\n\n"
    if analysis['missing_style']:
        report += f"**Total: {len(analysis['missing_style'])} hymns**\n\n"
        for hymn in analysis['missing_style']:
            report += f"- **#{hymn['number']}**: {hymn['title']}\n"
    else:
        report += "No hymns missing style information.\n"
    
    return report

def main():
    """Main function."""
    # File paths
    hymns_file = 'assets/data/hymns.json'
    output_file = 'hymns_analysis_report.md'
    updated_hymns_file = 'assets/data/hymns_updated.json'
    
    print("Loading hymns data...")
    hymns = load_hymns(hymns_file)
    print(f"Loaded {len(hymns)} hymns")
    
    print("Analyzing hymns for missing information...")
    analysis = analyze_hymns(hymns)
    
    
    print("Generating markdown report...")
    report = generate_markdown_report(analysis)
    
    # Write report to file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    # Write updated hymns to file
    with open(updated_hymns_file, 'w', encoding='utf-8') as f:
        json.dump(hymns, f, ensure_ascii=False, indent=2)
    
    print(f"\nReport generated: {output_file}")
    print(f"Updated hymns saved: {updated_hymns_file}")
    
    # Print summary
    print(f"\nSummary:")
    print(f"- Hymns missing author: {len(analysis['missing_author'])}")
    print(f"- Hymns missing composer: {len(analysis['missing_composer'])}")
    print(f"- Hymns missing style: {len(analysis['missing_style'])}")

if __name__ == "__main__":
    main()
