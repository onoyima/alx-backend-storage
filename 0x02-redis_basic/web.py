import redis
import requests
from functools import wraps
from typing import Callable

redis_store = redis.Redis()


def data_cacher(method: Callable) -> Callable:
    '''Caches the output of fetched data and tracks URL access counts.
    '''
    @wraps(method)
    def invoker(url: str) -> str:
        '''The wrapper function for caching the output.
        '''
        # Increment the count for the URL
        redis_store.incr(f'count:{url}')
        
        # Check if result is already cached
        result = redis_store.get(f'result:{url}')
        if result:
            return result.decode('utf-8')
        
        # Fetch the page content
        result = method(url)
        
        # Store the result in Redis with an expiration time of 10 seconds
        redis_store.setex(f'result:{url}', 10, result)
        
        return result
    
    return invoker

@data_cacher
def get_page(url: str) -> str:
    '''Fetches the content of a URL and caches the result.
    '''
    response = requests.get(url)
    return response.text
