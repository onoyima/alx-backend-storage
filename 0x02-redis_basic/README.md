# boniface project on this 
Overview
This project demonstrates how to interact with a Redis server using Python. The project includes two main scripts: exercise.py and web.py. The former provides a class to interact with Redis for caching purposes, while the latter demonstrates how to cache web page content using Redis.

File: exercise.py
Code Explanation
python
Copy code
#!/usr/bin/env python3
Shebang Line: Specifies the interpreter to be used for executing the script.
python
Copy code
"""Module to interact with Redis server."""
Docstring: A brief description of the module’s purpose.
python
Copy code
import redis
import uuid
from typing import Union, Callable, Optional
from functools import wraps
Imports:
redis: The Redis client library for Python.
uuid: Used to generate unique identifiers for cache keys.
typing: Provides type hints for function arguments and return values.
functools.wraps: A decorator that preserves the original function's metadata.
python
Copy code
class Cache:
    """Cache class to interact with Redis."""
Cache Class: A class that encapsulates methods for interacting with Redis, focusing on caching functionality.
python
Copy code
    def __init__(self):
        """Initialize the Redis client."""
        self._redis = redis.Redis()
        self._redis.flushdb()
Constructor:
Initializes the Redis client and clears the database.
python
Copy code
    def count_calls(self, method: Callable) -> Callable:
        """Decorator to count method calls."""
        @wraps(method)
        def wrapper(self, *args, **kwargs):
            key = method.__qualname__
            self._redis.incr(key)
            return method(self, *args, **kwargs)
        return wrapper
count_calls Method:
A decorator to count the number of times a method is called.
Increments a counter in Redis for each method call.
python
Copy code
    def call_history(self, method: Callable) -> Callable:
        """Decorator to store history of calls."""
        @wraps(method)
        def wrapper(self, *args, **kwargs):
            input_key = f"{method.__qualname__}:inputs"
            output_key = f"{method.__qualname__}:outputs"
            self._redis.rpush(input_key, str(args))
            result = method(self, *args, **kwargs)
            self._redis.rpush(output_key, str(result))
            return result
        return wrapper
call_history Method:
A decorator that records the history of method inputs and outputs in Redis.
python
Copy code
    @count_calls
    @call_history
    def store(self, data: Union[str, bytes, int, float]) -> str:
        """Store the data in Redis with a random key."""
        key = str(uuid.uuid4())
        self._redis.set(key, data)
        return key
store Method:
Stores data in Redis using a randomly generated key.
Decorated with count_calls and call_history to track usage and history.
python
Copy code
    def get(self, key: str, fn: Optional[Callable] = None) -> Union[str, bytes, int, float, None]:
        """Retrieve data from Redis and apply the optional function."""
        data = self._redis.get(key)
        if data and fn:
            return fn(data)
        return data
get Method:
Retrieves data from Redis by key and optionally applies a function (e.g., decoding or conversion).
python
Copy code
    def get_str(self, key: str) -> str:
        """Get a string value from Redis."""
        return self.get(key, fn=lambda d: d.decode("utf-8"))
get_str Method:
Retrieves and decodes a string value from Redis.
python
Copy code
    def get_int(self, key: str) -> int:
        """Get an integer value from Redis."""
        return self.get(key, fn=int)
get_int Method:
Retrieves and converts a value to an integer from Redis.
python
Copy code
def replay(method: Callable):
    """Display the history of calls of a particular function."""
    cache = Cache()
    inputs = cache._redis.lrange(f"{method.__qualname__}:inputs", 0, -1)
    outputs = cache._redis.lrange(f"{method.__qualname__}:outputs", 0, -1)
    print(f"{method.__qualname__} was called {len(inputs)} times:")
    for input_data, output_data in zip(inputs, outputs):
        print(f"{method.__qualname__}(*{input_data.decode('utf-8')}) -> {output_data.decode('utf-8')}")
replay Function:
Displays the call history for a specific method, showing both inputs and outputs.
File: web.py
Code Explanation
python
Copy code
#!/usr/bin/env python3
Shebang Line: Specifies the interpreter to be used for executing the script.
python
Copy code
"""Web caching and URL tracker using Redis."""
Docstring: A brief description of the module’s purpose.
python
Copy code
import redis
import requests
from typing import Callable
Imports:
redis: The Redis client library for Python.
requests: A library to make HTTP requests.
typing: Provides type hints for function arguments and return values.
python
Copy code
r = redis.Redis()
Redis Client Initialization: Initializes a Redis client instance to interact with the Redis server.
python
Copy code
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
get_page Function:
Takes a URL as input and returns the page content.
Increments a count for the URL in Redis each time it's requested.
Checks if the content is already cached in Redis. If so, it returns the cached content.
If not cached, fetches the page content from the web, caches it in Redis with a 10-second expiration, and returns it.
