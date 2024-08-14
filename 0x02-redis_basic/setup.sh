#!/bin/bash

# Ensure the script is run from the correct directory
if [ "$(basename "$PWD")" != "0x02-redis_basic" ]; then
    echo "Please run the script from the /alx-backend-storage/0x02-redis_basic/ directory."
    exit 1
fi

# Install Redis
sudo apt-get update
sudo apt-get -y install redis-server

# Install necessary Python packages
pip3 install redis pycodestyle requests

# Update Redis configuration to bind to localhost
sudo sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

# Start Redis server
sudo service redis-server start

# Create exercise.py file with the required tasks
cat <<EOL > exercise.py
#!/usr/bin/env python3
\"\"\"Module to interact with Redis server.\"\"\"

import redis
import uuid
from typing import Union, Callable, Optional
from functools import wraps

class Cache:
    \"\"\"Cache class to interact with Redis.\"\"\"

    def __init__(self):
        \"\"\"Initialize the Redis client.\"\"\"
        self._redis = redis.Redis()
        self._redis.flushdb()

    @wraps
    def count_calls(method: Callable) -> Callable:
        \"\"\"Decorator to count method calls.\"\"\"
        @wraps(method)
        def wrapper(self, *args, **kwargs):
            key = method.__qualname__
            self._redis.incr(key)
            return method(self, *args, **kwargs)
        return wrapper

    @wraps
    def call_history(method: Callable) -> Callable:
        \"\"\"Decorator to store history of calls.\"\"\"
        @wraps(method)
        def wrapper(self, *args, **kwargs):
            input_key = f"{method.__qualname__}:inputs"
            output_key = f"{method.__qualname__}:outputs"
            self._redis.rpush(input_key, str(args))
            result = method(self, *args, **kwargs)
            self._redis.rpush(output_key, str(result))
            return result
        return wrapper

    @count_calls
    @call_history
    def store(self, data: Union[str, bytes, int, float]) -> str:
        \"\"\"Store the data in Redis with a random key.\"\"\"
        key = str(uuid.uuid4())
        self._redis.set(key, data)
        return key

    def get(self, key: str, fn: Optional[Callable] = None) -> Union[str, bytes, int, float, None]:
        \"\"\"Retrieve data from Redis and apply the optional function.\"\"\"
        data = self._redis.get(key)
        if data and fn:
            return fn(data)
        return data

    def get_str(self, key: str) -> str:
        \"\"\"Get a string value from Redis.\"\"\"
        return self.get(key, fn=lambda d: d.decode("utf-8"))

    def get_int(self, key: str) -> int:
        \"\"\"Get an integer value from Redis.\"\"\"
        return self.get(key, fn=int)

def replay(method: Callable):
    \"\"\"Display the history of calls of a particular function.\"\"\"
    cache = Cache()
    inputs = cache._redis.lrange(f"{method.__qualname__}:inputs", 0, -1)
    outputs = cache._redis.lrange(f"{method.__qualname__}:outputs", 0, -1)
    print(f"{method.__qualname__} was called {len(inputs)} times:")
    for input_data, output_data in zip(inputs, outputs):
        print(f"{method.__qualname__}(*{input_data.decode('utf-8')}) -> {output_data.decode('utf-8')}")
EOL

# Create web.py file for advanced task
cat <<EOL > web.py
#!/usr/bin/env python3
\"\"\"Web caching and URL tracker using Redis.\"\"\"

import redis
import requests
from typing import Callable

r = redis.Redis()

def get_page(url: str) -> str:
    \"\"\"Fetch a page and cache the result with expiration.\"\"\"
    cache_key = f"count:{url}"
    r.incr(cache_key)
    cached_page = r.get(url)
    if cached_page:
        return cached_page.decode('utf-8')
    
    response = requests.get(url)
    content = response.text
    r.setex(url, 10, content)
    return content
EOL

# Create README.md
cat <<EOL > README.md
# ALX Backend Storage - Redis Basic

This project contains Python scripts to interact with Redis for various tasks. The tasks involve creating a caching mechanism, counting method calls, and tracking web pages using Redis.

## Files
- **exercise.py**: Contains the `Cache` class and decorators for caching, counting, and tracking history.
- **web.py**: Implements a simple web page caching and tracker using Redis.
EOL

# Make the scripts executable
chmod +x exercise.py web.py

echo "Setup complete. You can now run the Python scripts."

