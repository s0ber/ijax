/*! ijax (v0.2.1),
 ,
 by Sergey Shishkalov <sergeyshishkalov@gmail.com>
 Thu Jul 23 2015 */
(function() {
  var modules;

  modules = {};

  if (window.modula == null) {
    window.modula = {
      "export": function(name, exports) {
        return modules[name] = exports;
      },
      require: function(name) {
        var Module;
        Module = modules[name];
        if (Module) {
          return Module;
        } else {
          throw "Module '" + name + "' not found.";
        }
      }
    };
  }

}).call(this);

(function() {
  var Configuration;

  Configuration = (function() {
    function Configuration() {}

    Configuration.prototype.onRequestResolve = function(response, options, path) {};

    Configuration.prototype.onResponseFail = function(path) {};

    return Configuration;

  })();

  modula["export"]('ijax/configuration', Configuration);

}).call(this);

(function() {
  window.Ijax = (function() {
    var Configuration;

    Configuration = modula.require('ijax/configuration');

    _Class.config = function() {
      return this._config != null ? this._config : this._config = new Configuration();
    };

    _Class.configure = function(options) {
      return _.extend(this.config(), options);
    };

    function _Class() {
      this.IjaxRequest = modula.require('ijax/request');
      this.requests = {};
    }

    _Class.prototype.get = function(path) {
      var request;
      this.abortCurrentRequest();
      this.curRequest = request = new this.IjaxRequest(path);
      this.requests[request.id] = request;
      return request;
    };

    _Class.prototype.abortCurrentRequest = function() {
      var hasUnresolvedRequest, hasUnresolvedResponse, _ref;
      if (this.curRequest == null) {
        return;
      }
      hasUnresolvedRequest = !this.curRequest.isResolved;
      hasUnresolvedResponse = !((_ref = this.curRequest.response) != null ? _ref.isResolved : void 0);
      if ((hasUnresolvedRequest || hasUnresolvedResponse) && !this.curRequest.isRejected) {
        this.curRequest.reject();
        return this.removeRequest(this.curRequest);
      }
    };

    _Class.prototype.removeRequest = function(request) {
      delete this.requests[request.id];
      return delete this.curRequest;
    };

    _Class.prototype.registerResponse = function(requestId, responseOptions) {
      this.curRequest.registerResponse(responseOptions);
      return this.curRequest.resolve();
    };

    _Class.prototype.resolveResponse = function() {
      this.curRequest.response.resolve();
      return this.removeRequest(this.curRequest);
    };

    _Class.prototype.pushLayout = function(html) {
      return this.curRequest.response.addLayout(html);
    };

    _Class.prototype.pushFrame = function(frameId, frameHtml) {
      return this.curRequest.response.addFrame(frameId, frameHtml);
    };

    return _Class;

  })();

  modula["export"]('ijax', Ijax);

}).call(this);

(function() {
  var IjaxResponse;

  IjaxResponse = (function() {
    function IjaxResponse(options) {
      this.options = options;
      this.isResolved = false;
    }

    IjaxResponse.prototype.onResolve = function(onResolveCallback) {
      this.onResolveCallback = onResolveCallback;
      return this;
    };

    IjaxResponse.prototype.onLayoutReceive = function(onLayoutReceiveCallback) {
      this.onLayoutReceiveCallback = onLayoutReceiveCallback;
      return this;
    };

    IjaxResponse.prototype.onFrameReceive = function(onFrameReceiveCallback) {
      this.onFrameReceiveCallback = onFrameReceiveCallback;
      return this;
    };

    IjaxResponse.prototype.resolve = function() {
      this.isResolved = true;
      return typeof this.onResolveCallback === "function" ? this.onResolveCallback(this.options) : void 0;
    };

    IjaxResponse.prototype.addLayout = function(layoutHtml) {
      return typeof this.onLayoutReceiveCallback === "function" ? this.onLayoutReceiveCallback(layoutHtml) : void 0;
    };

    IjaxResponse.prototype.addFrame = function(frameId, frameHtml) {
      return typeof this.onFrameReceiveCallback === "function" ? this.onFrameReceiveCallback(frameId, frameHtml) : void 0;
    };

    return IjaxResponse;

  })();

  modula["export"]('ijax/response', IjaxResponse);

}).call(this);

(function() {
  var IjaxRequest;

  IjaxRequest = (function() {
    IjaxRequest.prototype.IjaxResponse = modula.require('ijax/response');

    function IjaxRequest(path) {
      this.id = this._getGuid();
      this.path = path;
      this.isResolved = false;
      this.isRejected = false;
      this.iframe = this.createIframeRequest();
      this.iframe.onload = _.bind(this.updateIframeStatus, this);
    }

    IjaxRequest.prototype.createIframeRequest = function(appendToDom) {
      var iframe, src, tmpElem;
      if (appendToDom == null) {
        appendToDom = true;
      }
      src = this.path || 'javascript:false';
      tmpElem = document.createElement('div');
      tmpElem.innerHTML = "<iframe name=\"" + this.id + "\" id=\"" + this.id + "\" src=\"" + src + "\">";
      iframe = tmpElem.firstChild;
      iframe.style.display = 'none';
      if (appendToDom) {
        document.body.appendChild(iframe);
      }
      return iframe;
    };

    IjaxRequest.prototype.registerResponse = function(responseOptions) {
      responseOptions = _.extend({
        path: this.path
      }, responseOptions);
      return this.response = new this.IjaxResponse(responseOptions);
    };

    IjaxRequest.prototype.done = function(onDoneCallback) {
      this.onDoneCallback = onDoneCallback;
      return this;
    };

    IjaxRequest.prototype.fail = function(onFailCallback) {
      this.onFailCallback = onFailCallback;
      return this;
    };

    IjaxRequest.prototype.resolve = function() {
      this.isResolved = true;
      if (Ijax.config().onRequestResolve(this.response, this.response.options, this.path) === false) {
        return this.reject();
      } else {
        return typeof this.onDoneCallback === "function" ? this.onDoneCallback(this.response) : void 0;
      }
    };

    IjaxRequest.prototype.reject = function() {
      this.isRejected = true;
      if (typeof this.onFailCallback === "function") {
        this.onFailCallback();
      }
      return this.removeIframe();
    };

    IjaxRequest.prototype.updateIframeStatus = function() {
      this.removeIframe();
      if (!this.isResolved || !this.response.isResolved) {
        return this.showError();
      }
    };

    IjaxRequest.prototype.showError = function() {
      return Ijax.config().onResponseFail(this.path);
    };

    IjaxRequest.prototype.removeIframe = function() {
      var _ref;
      return (_ref = this.iframe.parentNode) != null ? _ref.removeChild(this.iframe) : void 0;
    };

    IjaxRequest.prototype._getGuid = function() {
      return this._s4() + this._s4() + '-' + this._s4() + '-' + this._s4() + '-' + this._s4() + '-' + this._s4() + this._s4() + this._s4();
    };

    IjaxRequest.prototype._s4 = function() {
      return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    };

    return IjaxRequest;

  })();

  modula["export"]('ijax/request', IjaxRequest);

}).call(this);
