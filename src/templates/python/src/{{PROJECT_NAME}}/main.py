"""
Main entry point for {{PROJECT_NAME}}.

Created on {{DATE}} by {{AUTHOR}}.
"""

import argparse


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        prog="{{PROJECT_NAME}}",
        description="{{PROJECT_NAME}} - AI-agent project",
    )
    parser.add_argument(
        "--version",
        action="version",
        version="%(prog)s 0.1.0",
    )
    parser.add_argument(
        "name",
        nargs="?",
        default="World",
        help="Name to greet (default: World)",
    )

    args = parser.parse_args()
    print(f"Hello from {{PROJECT_NAME}}, {args.name}!")


if __name__ == "__main__":
    main()
