#!/usr/bin/env python3
"""Web caching and URL tracker using Redis."""

import redis
import requests
from typing import Callable

r = redis.Redis()


def get_page(url: str) -> str:
    """Fetch a page and cache the result with expiration."""
    cache_key = f"count:{url}"
    r.incr(cache_key)
    cached_page = r.get(url)
    if cached_page:
        return cached_page.decode('utf-8')
    
    response = requests.get(url)
    content = response.text
    r.setex(url, 10, content)
    return content
