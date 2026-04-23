#!/usr/bin/env python3
import sys, os, urllib.request

port = os.environ.get('PORT', '5050')
try:
    urllib.request.urlopen(f'http://localhost:{port}/login', timeout=5)
    sys.exit(0)
except Exception:
    sys.exit(1)
