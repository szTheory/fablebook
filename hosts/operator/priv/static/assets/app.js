(() => {
  const announceCanvasState = (state, screen) => {
    if (window.parent === window) return;

    try {
      window.parent.postMessage(
        { type: "fablebook:canvas", state, screen },
        window.location.origin
      );
    } catch (_error) {
      // A parent that is no longer available leaves its own loading status intact.
    }
  };

  const frame = document.querySelector("[data-canvas-frame]");
  const status = document.querySelector("[data-canvas-status]");

  if (frame && status) {
    let incompleteTimer;
    let statusRequestTimer;
    const failureMessage =
      "The screen could not load. Check that the local Phoenix host is running, then reload.";
    const currentScreen = () => frame.dataset.screen;
    const currentScreenName = () => frame.title;
    const stopStatusRequests = () => {
      window.clearTimeout(statusRequestTimer);
      statusRequestTimer = undefined;
    };

    const fail = () => {
      window.clearTimeout(incompleteTimer);
      stopStatusRequests();
      setStatus("failed", failureMessage);
    };

    const setStatus = (state, message) => {
      status.dataset.canvasStatus = state;
      status.textContent = message;
    };

    const hasCanvasDocument = () => {
      try {
        return frame.contentDocument?.querySelector("[data-canvas-document]") != null;
      } catch (_error) {
        return false;
      }
    };

    const isExpectedFrameDocument = () => {
      try {
        const expectedUrl = new URL(frame.getAttribute("src"), window.location.href).href;
        return frame.contentWindow.location.href === expectedUrl;
      } catch (_error) {
        return false;
      }
    };

    const beginIncompleteTimer = () => {
      window.clearTimeout(incompleteTimer);
      incompleteTimer = window.setTimeout(() => {
        fail();
      }, 8000);
    };

    const requestCanvasStatus = () => {
      if (!isExpectedFrameDocument() || status.dataset.canvasStatus !== "incomplete") return;

      try {
        frame.contentWindow.postMessage(
          { type: "fablebook:canvas-status-request", screen: currentScreen() },
          window.location.origin
        );
      } catch (_error) {
        fail();
        return;
      }

      statusRequestTimer = window.setTimeout(requestCanvasStatus, 250);
    };

    const handleFrameLoad = () => {
      // A deferred host script can run after the iframe's load event. Ignore
      // its initial about:blank document and inspect the requested Canvas URL.
      if (!isExpectedFrameDocument()) return;

      if (!hasCanvasDocument()) {
        window.clearTimeout(incompleteTimer);
        fail();
        return;
      }

      const screenName = currentScreenName();
      setStatus("incomplete", `Canvas document loaded; waiting for ${screenName}.`);
      beginIncompleteTimer();
      stopStatusRequests();
      requestCanvasStatus();
    };

    frame.addEventListener("load", handleFrameLoad);

    frame.addEventListener("error", () => {
      window.clearTimeout(incompleteTimer);
      fail();
    });

    window.addEventListener("message", (event) => {
      if (event.origin !== window.location.origin || event.source !== frame.contentWindow) return;

      const message = event.data;
      if (!message || message.type !== "fablebook:canvas" || message.screen !== currentScreen()) return;

      if (message.state === "ready") {
        window.clearTimeout(incompleteTimer);
        stopStatusRequests();
        setStatus("ready", `Screen ready: ${currentScreenName()}.`);
      } else if (message.state === "failed") {
        window.clearTimeout(incompleteTimer);
        fail();
      }
    });

    beginIncompleteTimer();

    // The iframe can finish before this deferred script installs its listener.
    if (frame.contentDocument?.readyState === "complete") handleFrameLoad();
  }

  const canvasScreen = document.querySelector("#canvas-screen");
  const hooks = {
    FablebookCanvas: {
      mounted() {
        const screen = this.el.dataset.screen;
        announceCanvasState("ready", screen);
      }
    }
  };

  if (canvasScreen) {
    window.addEventListener("message", (event) => {
      if (event.origin !== window.location.origin || event.source !== window.parent) return;

      const message = event.data;
      if (
        message &&
        message.type === "fablebook:canvas-status-request" &&
        message.screen === canvasScreen.dataset.screen
      ) {
        announceCanvasState("ready", canvasScreen.dataset.screen);
      }
    });
  }

  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
  if (window.Phoenix && window.LiveView && csrfToken) {
    const liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket, {
      hooks,
      params: { _csrf_token: csrfToken }
    });

    liveSocket.connect();
    window.fablebookLiveSocket = liveSocket;
  }
})();
