// ==UserScript==
// @name                Save Pinterest images to Eagle

// @description         Launch a script on Pinterest that automatically scrolls the page and converts all images on the page into large images (with links, names) to be added to the Eagle App.

// @author              Augus
// @namespace           https://eagle.cool/
// @homepageURL         https://eagle.cool/
// @license             MIT License

// @match               https://www.pinterest.com/*
// @grant               GM_xmlhttpRequest
// @run-at              context-menu

// @date                06/16/2020
// @modified            06/16/2020
// @version             0.0.3

// ==/UserScript==


(function() {

    if (location.href.indexOf("pinterest.com") === -1) {
        alert("This script only works on pinterest.com.");
        return;
    }

    // Eagle API URL
    const EAGLE_SERVER_URL = "http://localhost:41595";
    const EAGLE_IMPORT_API_URL = `${EAGLE_SERVER_URL}/api/item/addFromURLs`;
    const EAGLE_CREATE_FOLDER_API_URL = `${EAGLE_SERVER_URL}/api/folder/create`;

    // Pinterest Rules
    const SELECTOR_IMAGE = "[data-grid-item] a img[srcset]";
    const SELECTOR_LINK = "[data-grid-item] a";
    const SELECTOR_SPINNER = `[aria-label="Board Pins grid"]`;

    var startTime = Date.now();
    var scrollInterval;
    var lastScrollPos;
    var retryCount = 0;
    var scrollDelay = 500;
    var retryThreshold = 4;
    var pageInfo = {
        imageCount: 0,
        imageSet: {},
        folderId: ""
    };

    // Create a folder
    var createFolder = function(folderName, callback) {
        GM_xmlhttpRequest({
            url: EAGLE_CREATE_FOLDER_API_URL,
            method: "POST",
            data: JSON.stringify({ folderName: folderName }),
            onload: function(response) {
                try {
                    var result = JSON.parse(response.response);
                    if (result.status === "success" && result.data && result.data.id) {
                        callback(undefined, result.data);
                    } else {
                        callback(true);
                    }
                } catch (err) {
                    callback(true);
                }
            }
        });
    };

    var scarollToTop = function() {
        window.scrollTo(0, 0);
        lastScrollPos = window.scrollY;
    };

    var scarollToBottom = function() {
        window.scrollTo(0, document.body.scrollHeight);
        lastScrollPos = window.scrollY;
    };

    var getImgs = function() {
        var imgs = [];
        var imgElements = Array.from(document.querySelectorAll(SELECTOR_IMAGE));

        imgElements = imgElements.filter(function(elem) {
            var src = elem.src;
            if (!pageInfo.imageSet[src]) {
                pageInfo.imageSet[src] = true;
                return true;
            }
            return false;
        });

        var getLink = function(img) {
            var links = Array.from(document.querySelectorAll(SELECTOR_LINK));
            for (var i = 0; i < links.length; i++) {
                if (links[i].contains(img)) {
                    return absolutePath(links[i].href);
                }
            }
            return "";
        };

        imgs = imgElements.map(function(elem, index) {
            pageInfo.imageCount++;
            return {
                name: elem.alt || "",
                url: getHighestResImg(elem) || elem.src,
                website: getLink(elem),
                modificationTime: startTime - pageInfo.imageCount
            }
        });

        return imgs;
    };

    var fetchImages = function() {
        var currentScrollPos = window.scrollY;
        scarollToBottom();

        if (lastScrollPos === currentScrollPos) {
            if (!document.querySelector(SELECTOR_SPINNER)) {
                retryCount++;
                if (retryCount >= retryThreshold) {
                    clearInterval(scrollInterval);
                    alert(`Scan completed, a total of ${pageInfo.imageCount} images have been added to Eagle App.`);
                }
            }
        }
        else {
            retryCount = 0;
            var images = getImgs();
            addImagesToEagle(images);
        }
    }

    var addImagesToEagle = function(images) {
        GM_xmlhttpRequest({
            url: EAGLE_IMPORT_API_URL,
            method: "POST",
            data: JSON.stringify({ items: images, folderId: pageInfo.folderId }),
            onload: function(response) {}
        });
    }

    function absolutePath(href) {
        if (href && href.indexOf(" ") > -1) {
            href = href.trim().split(" ")[0];
        }
        var link = document.createElement("a");
        link.href = href;
        return link.href;
    }

    function getHighestResImg(element) {
        if (element.getAttribute('srcset')) {
            let highResImgUrl = '';
            let maxRes = 0;
            let imgWidth, urlWidthArr;
            element.getAttribute('srcset').split(',').forEach((item) => {
                urlWidthArr = item.trim().split(' ');
                imgWidth = parseInt(urlWidthArr[1]);
                if (imgWidth > maxRes) {
                    maxRes = imgWidth;
                    highResImgUrl = urlWidthArr[0];
                }

            });
            return highResImgUrl;
        } else {
            return element.getAttribute('src');
        }
    }

    scarollToTop();

    var folderName = document.querySelector("h1") && document.querySelector("h1").innerText || "Pinterest";
    createFolder(folderName, function(err, folder) {
        if (folder) {
            pageInfo.folderId = folder.id;
            scrollInterval = setInterval(fetchImages, 1000);
        } else {
            alert("An error has occurred or the Eagle app is not open.");
        }
    });

})();