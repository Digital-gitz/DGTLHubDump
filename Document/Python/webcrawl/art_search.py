#!/usr/bin/env python3
"""
Multi-Platform Art Search Script
Searches multiple art platforms and opens results in browser
"""

import webbrowser
import urllib.parse
import time
import sys
import argparse
from typing import Dict, List, Optional
from dataclasses import dataclass


@dataclass
class Platform:
    """Represents an art platform with its search URL template"""
    name: str
    url_template: str
    enabled: bool = True
    description: str = ""


# Define all available platforms
PLATFORMS: Dict[str, Platform] = {
    "pinterest": Platform(
        name="Pinterest",
        url_template="https://www.pinterest.com/search/pins/?q={query}",
        description="Image discovery and inspiration"
    ),
    "artstation": Platform(
        name="ArtStation",
        url_template="https://www.artstation.com/search?query={query}&sort_by=relevance",
        description="Professional digital art portfolio"
    ),
    "deviantart": Platform(
        name="DeviantArt",
        url_template="https://www.deviantart.com/search?q={query}",
        description="Art community and gallery"
    ),
    "conceptart": Platform(
        name="ConceptArt.org",
        url_template="https://www.conceptart.org/search/?q={query}",
        description="Concept art community"
    ),
    "behance": Platform(
        name="Behance",
        url_template="https://www.behance.net/search?search={query}",
        description="Creative portfolio platform"
    ),
    "dribbble": Platform(
        name="Dribbble",
        url_template="https://dribbble.com/search/{query}",
        description="Design inspiration and portfolios"
    ),
    "instagram": Platform(
        name="Instagram (Hashtag)",
        url_template="https://www.instagram.com/explore/tags/{query}/",
        description="Social media hashtag search"
    ),
    "reddit": Platform(
        name="Reddit /r/Art",
        url_template="https://www.reddit.com/r/Art/search/?q={query}&restrict_sr=1",
        description="Reddit art community"
    ),
    # Pixiv is disabled by default due to access issues
    "pixiv": Platform(
        name="Pixiv",
        url_template="https://www.pixiv.net/en/artworks?word={query}",
        enabled=False,
        description="Japanese art community (may have access restrictions)"
    ),
}


def get_platform_url(platform: Platform, query: str) -> str:
    """Generate search URL for a platform"""
    encoded_query = urllib.parse.quote(query)
    return platform.url_template.format(query=encoded_query)


def search_art_platforms(
    query: str,
    platform_keys: Optional[List[str]] = None,
    delay: float = 0.5
) -> Dict[str, bool]:
    """
    Search multiple art platforms and open results in browser
    
    Args:
        query: Search term(s) to look for
        platform_keys: List of platform keys to search (None = all enabled platforms)
        delay: Delay between opening tabs (seconds)
    
    Returns:
        Dictionary mapping platform names to success status
    """
    if not query or not query.strip():
        print("Error: Please provide a non-empty search query")
        return {}
    
    query = query.strip()
    encoded_query = urllib.parse.quote(query)
    
    # Filter platforms
    if platform_keys is None:
        platforms_to_search = {
            key: platform for key, platform in PLATFORMS.items()
            if platform.enabled
        }
    else:
        platforms_to_search = {}
        for key in platform_keys:
            key_lower = key.lower()
            if key_lower in PLATFORMS:
                platforms_to_search[key_lower] = PLATFORMS[key_lower]
            else:
                print(f"Warning: Unknown platform '{key}', skipping...")
    
    if not platforms_to_search:
        print("Error: No valid platforms selected")
        return {}
    
    print(f"\n🔍 Searching for: '{query}'")
    print(f"📱 Opening {len(platforms_to_search)} platform(s) in your browser...\n")
    
    results = {}
    
    # Open each platform in the browser
    for key, platform in platforms_to_search.items():
        try:
            url = get_platform_url(platform, query)
            print(f"  ✓ Opening {platform.name}...", end=" ", flush=True)
            webbrowser.open(url)
            results[platform.name] = True
            print("✓")
            time.sleep(delay)
        except Exception as e:
            print(f"✗ Error: {e}")
            results[platform.name] = False
    
    successful = sum(1 for success in results.values() if success)
    print(f"\n✅ Successfully opened {successful}/{len(platforms_to_search)} platform(s)!")
    
    return results


def list_platforms() -> None:
    """Display all available platforms"""
    print("\nAvailable Platforms:")
    print("=" * 60)
    for key, platform in sorted(PLATFORMS.items()):
        status = "✓ Enabled" if platform.enabled else "✗ Disabled"
        print(f"  • {platform.name:20} ({key:12}) - {status}")
        if platform.description:
            print(f"    {platform.description}")
    print()


def interactive_mode() -> str:
    """Get search query interactively"""
    print("\n" + "=" * 60)
    print("Multi-Platform Art Search - Interactive Mode")
    print("=" * 60)
    print("\nEnter your search query (or 'quit' to exit):")
    query = input("> ").strip()
    return query


def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Search multiple art platforms simultaneously",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s "fantasy landscape"
  %(prog)s "cyberpunk character design" --platforms pinterest artstation
  %(prog)s "nature art" --platforms all
  %(prog)s --list
  %(prog)s --interactive
        """
    )
    
    parser.add_argument(
        "query",
        nargs="*",
        help="Search query (words will be joined with spaces)"
    )
    
    parser.add_argument(
        "-p", "--platforms",
        nargs="+",
        help="Specific platforms to search (use 'all' for all enabled platforms, or --list to see options)"
    )
    
    parser.add_argument(
        "-l", "--list",
        action="store_true",
        help="List all available platforms and exit"
    )
    
    parser.add_argument(
        "-i", "--interactive",
        action="store_true",
        help="Run in interactive mode"
    )
    
    parser.add_argument(
        "-d", "--delay",
        type=float,
        default=0.5,
        help="Delay between opening browser tabs in seconds (default: 0.5)"
    )
    
    return parser.parse_args()


def main():
    """Main function to handle command line arguments and execution"""
    args = parse_arguments()
    
    # List platforms and exit
    if args.list:
        list_platforms()
        return
    
    # Interactive mode
    if args.interactive:
        while True:
            query = interactive_mode()
            if not query or query.lower() in ('quit', 'exit', 'q'):
                print("\nGoodbye! 👋")
                break
            
            platform_keys = None
            if args.platforms:
                if 'all' in args.platforms:
                    platform_keys = None
                else:
                    platform_keys = args.platforms
            
            search_art_platforms(query, platform_keys, args.delay)
            print("\n" + "-" * 60 + "\n")
        return
    
    # Get query from arguments
    if not args.query:
        print("Multi-Platform Art Search Script")
        print("=" * 60)
        print("\nUsage: python art_search.py <search query> [options]")
        print("\nOptions:")
        print("  -p, --platforms PLATFORM ...  Select specific platforms")
        print("  -l, --list                   List all available platforms")
        print("  -i, --interactive            Run in interactive mode")
        print("  -d, --delay SECONDS          Delay between tabs (default: 0.5)")
        print("\nUse --help for more information and examples")
        print("\nOr use --interactive for interactive mode")
        sys.exit(1)
    
    # Join query arguments
    search_query = " ".join(args.query)
    
    # Determine which platforms to search
    platform_keys = None
    if args.platforms:
        if 'all' in args.platforms:
            platform_keys = None  # All enabled platforms
        else:
            platform_keys = [p.lower() for p in args.platforms]
    
    # Perform search
    search_art_platforms(search_query, platform_keys, args.delay)


if __name__ == "__main__":
    main()