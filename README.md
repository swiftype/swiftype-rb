# Swiftype::Easy - Simple Swiftype API Client with no dependencies

This is a simple client for the Swiftype API with no dependencies outside core Ruby (for 1.9; Ruby 1.8 require the JSON gem).

This library is a direct pass-through to the Swiftype API. It does not use intermediate objects or return them. All parameters and return values are simple Ruby objects.

We are providing this library for users who may not be able to install our other gem due to dependency conflicts, 
but would like an easier way to access the API than constructing requests by hand.

For a more full-featured API library, see [swiftype-rb](https://github.com/swiftype/swiftype-rb)

## Todo

* Add specs with webmock 
