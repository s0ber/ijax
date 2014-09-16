Ijax
=====
[![Build Status](https://travis-ci.org/s0ber/ijax.png?branch=master)](https://travis-ci.org/s0ber/ijax)

Library for creating GET ajax requests via iframe. There is also built-in support for streaming parts of data via iframe.

## API

You need to create an instance of Ijax class, and then work with this instance. It'll have following methods.

## class Ijax

### ijax.get(path)

**[IjaxRequest]**

This will create a new request to provided path. Request will have unique id, which will be added to query string.
Request object will be returned. Once request is created, you need to push data to browser from responding iframe with following methods (in a following order).

### ijax.registerResponse(requestId)

This will resolve your GET request, and ```.done``` callback for a request will be called, with response object provided to it. You can push data to this response with next two methods.

### ijax.pushLayout(html)

This will push some data to a response ```.onLayoutReceive``` callback.

### ijax.pushFrame(frameId, frameHtml)

This will push some partial data to a response ```.onFrameReceive``` callback.

### ijax.resolveResponse()

This will finally resolve a response for a request.


## class IjaxRequest

Instance of this class is returned, when you are creating a request with ```ijax.get('/some_path')```.
You can add some very important callbacks for this request.

### request.done(callback)

This callback will be called, when request will be resolved by a server (request, but not a response). Response object for this particular request will be passed as the only argument.

### request.fail(callback)

This callback will be called, when request will be aborted or failed.

## class IjaxResponse

Instance of this class is created, when server resolves a request, and passed as the only argument to request's resolving callback.

This response object also have some important callbacks, with help of them you can render your page part by part.

### response.onLayoutReceive(callback)

This callback will be called, when server will push layout for a page. Layout html should be passed to this callback as the only argument with a help of ```ijax.pushLayout``` function.

### response.onFrameReceive(callback)

This callback will be called, when server will push a fragment of a page. Id of a fragment and fragment's html should be provided to this callback with a help of ```ijax.pushFrame``` function.

### response.onResolve(callback)

This callback will be called, when response will be completely resolved by server and server will close a connection.


## Why would anyone ever need this?

If you reading this, then you might be interested of why would someone will need stuff like this. The truth is, that at current point in time iframe it the only cross-browser way of executing code snippets while receiving them from server. It means, that you can execute code as fast, as you receive it. You don't need to wait for a whole content to start working with a response. You can get data (for example, html) from server by chunks, and show those chunks immediately. When used properly, this can improve user experience a lot. Such approach is used by VK and Facebook. But with this library you can easily apply it to your web application.
