#!/usr/bin/env python3
import json
import re


def format_stanza(stanza_text, stanza_number):
    """Format a single stanza with proper line breaks and numbering"""
    if not stanza_text.strip():
        return ""
    
    # Clean up the stanza text - preserve the natural line breaks from the original
    text = stanza_text.strip()
    
    # Split into lines and clean each line
    lines = []
    for line in text.split('\n'):
        line = line.strip()
        if line:  # Only add non-empty lines
            lines.append(line)
    
    # Format the stanza with number
    if stanza_number and lines:
        result = f"{stanza_number}.\n" + "\n".join(lines)
    else:
        result = "\n".join(lines)
    
    return result


def convert_hymne_to_json(hymne_text):
    """Convert a single hymne from Dart format to JSON format"""
    
    # Extract number
    number_match = re.search(r"number:\s*'(\d+)'", hymne_text)
    number = number_match.group(1) if number_match else ""
    
    # Extract title - clean up formatting
    # Handle escaped quotes properly: match everything until unescaped quote
    titre_match = re.search(r"titre:\s*'((?:[^'\\]|\\.)*)'", hymne_text)
    if titre_match:
        title = titre_match.group(1).strip()
        # Replace escaped quotes with regular quotes
        title = title.replace("\\'", "'")
        # Remove trailing punctuation like "!" or "..." if it seems excessive
        title = re.sub(r'\s*[.]{3,}$', '', title)  # Remove trailing dots
        title = title.strip()
    else:
        title = ""
    
    # Extract lyrics (chant) - handle multi-line strings with proper formatting
    # Look for chant: followed by a quoted string, ending at ',\n        style:'
    chant_match = re.search(r"chant:\s*'(.*?)',\s*style:", hymne_text, re.DOTALL)
    if chant_match:
        lyrics = chant_match.group(1)
        
        # First, let's split by the stanza markers before replacing escaped characters
        # The pattern in the raw data is \t NUMBER \n (with literal backslashes)
        stanza_pattern = r'\\t\s*(\d+)\s*\\n'
        parts = re.split(stanza_pattern, lyrics)
        
        stanzas = []
        
        # parts[0] is any text before first stanza (usually empty)
        # parts[1] is first stanza number, parts[2] is first stanza content
        # parts[3] is second stanza number, parts[4] is second stanza content, etc.
        
        for i in range(1, len(parts), 2):
            if i + 1 < len(parts):
                stanza_number = parts[i].strip()
                stanza_content = parts[i + 1].strip()
                
                if stanza_content:
                    # Now replace escaped characters in the stanza content
                    stanza_content = stanza_content.replace("\\n", "\n").replace("\\'", "'")
                    formatted_stanza = format_stanza(stanza_content, stanza_number)
                    if formatted_stanza:
                        stanzas.append(formatted_stanza)
        
        # Join stanzas with double line breaks
        lyrics = "\n\n".join(stanzas)
        
    else:
        lyrics = ""
    
    # Extract author
    # Handle escaped quotes properly: match everything until unescaped quote
    auteur_match = re.search(r"auteur:\s*'((?:[^'\\]|\\.)*)'", hymne_text)
    if auteur_match:
        author = auteur_match.group(1).strip()
        # Replace escaped quotes with regular quotes
        author = author.replace("\\'", "'")
        author = author.strip()
    else:
        author = ""
    
    # Extract composer (musicien)
    # Handle escaped quotes properly: match everything until unescaped quote
    musicien_match = re.search(r"musicien:\s*'((?:[^'\\]|\\.)*)'", hymne_text)
    if musicien_match:
        composer = musicien_match.group(1).strip()
        # Replace escaped quotes with regular quotes
        composer = composer.replace("\\'", "'")
        composer = composer.strip()
    else:
        composer = ""
    
    # Extract style - handle escaped quotes properly
    style_match = re.search(r"style:\s*'((?:[^'\\]|\\.)*)'", hymne_text)
    if style_match:
        style = style_match.group(1).strip()
        # Replace escaped quotes with regular quotes
        style = style.replace("\\'", "'")
        style = style.strip()
    else:
        style = ""
    
    # Extract audio files
    soprano_match = re.search(r"soprano:\s*'([^']*)'", hymne_text)
    soprano = soprano_match.group(1) if soprano_match else f"S{number.zfill(3)}"
    
    alto_match = re.search(r"alto:\s*'([^']*)'", hymne_text)
    alto = alto_match.group(1) if alto_match else f"A{number.zfill(3)}"
    
    tenor_match = re.search(r"tenor:\s*'([^']*)'", hymne_text)
    tenor = tenor_match.group(1) if tenor_match else f"T{number.zfill(3)}"
    
    basse_match = re.search(r"basse:\s*'([^']*)'", hymne_text)
    bass = basse_match.group(1) if basse_match else f"B{number.zfill(3)}"
    
    # Create JSON object
    hymne_json = {
        "number": number,
        "title": title,
        "lyrics": lyrics,
        "author": author,
        "composer": composer,
        "style": style,
        "sopranoFile": soprano,
        "altoFile": alto,
        "tenorFile": tenor,
        "bassFile": bass,
        "midiFile": f"h{number}"
    }
    
    return hymne_json

def extract_hymnes_from_dart(file_path):
    """Extract all hymnes from the Dart file and convert to JSON"""
    
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Find the hymnesBank list
    start_marker = "List<Hymne> _hymnesBank = ["
    end_marker = "];"
    
    start_idx = content.find(start_marker)
    if start_idx == -1:
        print("Could not find hymnesBank list")
        return []
    
    start_idx += len(start_marker)
    end_idx = content.find(end_marker, start_idx)
    
    if end_idx == -1:
        print("Could not find end of hymnesBank list")
        return []
    
    hymnes_content = content[start_idx:end_idx]
    
    # Split by Hymne( and process each one
    hymne_parts = hymnes_content.split("Hymne(")
    hymns = []
    
    for i, part in enumerate(hymne_parts[1:], 1):  # Skip first empty part
        try:
            # Find the closing parenthesis for this hymne
            paren_count = 0
            end_pos = 0
            for j, char in enumerate(part):
                if char == '(':
                    paren_count += 1
                elif char == ')':
                    paren_count -= 1
                    if paren_count < 0:
                        end_pos = j
                        break
            
            if end_pos > 0:
                hymne_text = part[:end_pos]
                hymne_json = convert_hymne_to_json(hymne_text)
                if hymne_json["number"]:  # Only add if we have a valid number
                    hymns.append(hymne_json)
                    if i <= 10 or i % 50 == 0:  # Show first 10 and every 50th
                        print(f"Converted hymn {hymne_json['number']}: {hymne_json['title']}")
        except Exception as e:
            print(f"Error converting hymn {i}: {e}")
    
    # Sort by number
    hymns.sort(key=lambda x: int(x["number"]))
    
    return hymns

def test_conversion():
    """Test the conversion on a few sample hymns"""
    print("Testing conversion on sample hymns...")
    
    input_file = "assets/data/HymnesBrain.dart"
    
    # Let's debug the raw extraction first
    with open(input_file, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Find the first hymn to debug
    start_marker = "List<Hymne> _hymnesBank = ["
    start_idx = content.find(start_marker) + len(start_marker)
    first_hymn_start = content.find("Hymne(", start_idx)
    first_hymn_end = content.find("Hymne(", first_hymn_start + 1)
    
    if first_hymn_end == -1:
        first_hymn_end = content.find("];", first_hymn_start)
    
    first_hymn_raw = content[first_hymn_start:first_hymn_end]
    print("RAW FIRST HYMN:")
    print(repr(first_hymn_raw[:500]))  # Show first 500 chars
    print("\n" + "="*50)
    
    hymns = extract_hymnes_from_dart(input_file)
    
    # Show first 3 hymns for testing
    for i in range(min(3, len(hymns))):
        hymn = hymns[i]
        print(f"\n{'='*50}")
        print(f"HYMN {hymn['number']}: {hymn['title']}")
        print(f"{'='*50}")
        print("LYRICS:")
        if hymn['lyrics']:
            print(hymn['lyrics'])
        else:
            print("EMPTY")
        print(f"Author: {hymn['author']}")
        print(f"Composer: {hymn['composer']}")
        print(f"Style: {hymn['style']}")


def main():
    """Main function to convert the hymns"""
    
    input_file = "assets/data/HymnesBrain.dart"
    output_file = "assets/data/hymns.json"
    
    # Ask user if they want to test first
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        test_conversion()
        return
    
    print("Starting hymn conversion...")
    hymns = extract_hymnes_from_dart(input_file)
    
    print(f"\nConverted {len(hymns)} hymns")
    
    # Write to JSON file
    with open(output_file, 'w', encoding='utf-8') as file:
        json.dump(hymns, file, ensure_ascii=False, indent=2)
    
    print(f"JSON file written to {output_file}")
    
    # Print some statistics
    print(f"\nStatistics:")
    print(f"Total hymns: {len(hymns)}")
    if hymns:
        print(f"First hymn: {hymns[0]['number']} - {hymns[0]['title']}")
        print(f"Last hymn: {hymns[-1]['number']} - {hymns[-1]['title']}")

if __name__ == "__main__":
    main()
