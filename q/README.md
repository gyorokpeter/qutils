# Utilities

## HTML API

The original motivation for this API is to both allow multiple HTML-based apps to coexist inside a single q process (on my home PC I use a single "apploader" that loads all my apps), as well as make it easier to parse GET/POST parameters and render response pages.

* **Multiplexing**: Function names can be put into the ```.html.commandHandlers``` dictionary to map them to paths in the HTTP request. For GET requests, the part before the "?" is the path (without the leading "/"). The function receives a dictionary of all the GET or POST parameters.
* **Single handler**: Both GET and POST requests are handled by the same handler.
* **Debugging**: If an error occurs in the handler, a stack trace is printed.
* Utility functions:
 * ```.html.page[title;body]```: generate the full HTTP response including headers.
 * ```.html.table[t]```: convert a table to HTML.
 * ```.html.fastredirect[path]```: redirect to a different URL.
 * ```.html.es[str]```: escape a string for display in HTML. The set of characters escaped may be extended in the future.
 * ```.html.unes[str]```: unescape a string. The set of characters unescaped may be extended in the future.
