function addOverflowVisibleCSSClass() {
    if (window.hasOwnProperty('$addedOverflowVisibleCSSClass')) return;
    window.$addedOverflowVisibleCSSClass = true;

    const head = document.querySelector('head');
    const injectedStyles = document.createElement('style');
    injectedStyles.innerText = '.c-overflow-visible { overflow: visible !important; }';
    head.appendChild(injectedStyles);
}

function addModalRelatedObservers() {
    if (window.hasOwnProperty('$addedOverlayObserver')) return;
    window.$addedOverlayObserver = true;

    addOverflowVisibleCSSClass();

     // Observer to detect when a lightning-overlay-container is inserted in DOM
    const observer = new MutationObserver(function (mutations) {
        // When a lightning-overlay-container is added to DOM, add the slds-scope class to the container
        const overlayContainers = document.querySelectorAll('lightning-overlay-container:not(.slds-scope)');
        for (let i = 0; i < overlayContainers.length; i++) {
            const overlayContainer = overlayContainers[i];

            // add the slds scope class to ensure SLDS styling
            overlayContainer.classList.add('slds-scope');

            addOverflowAddingObserver(overlayContainer);
        }
    });
    
    // Watch page to look out for lightning-overlay-container being added
    observer.observe(
        document.querySelector('body'),
        { 
            attributes: false,
            childList: true,
            characterData: false,
            subtree: false
        }
    );
}

function addOverflowAddingObserver(elem) {
    if (elem.hasAttribute('enabledOverflowObserver')) return;
    elem.setAttribute('enabledOverflowObserver', '');

    /**
     * Add the overflow class to each modal that has an element in the modal's body with class .dynamic-add-overflow-to-modal
     */
    addOverflowIfNeeded = () => {
        const modalBases = elem.shadowRoot.querySelectorAll('lightning-modal-base');
        for (let i = 0; i < modalBases.length; i++) {
            const modalBase = modalBases[i];

            // Get the actual modal node
            const modal = modalBase.shadowRoot.querySelector('lightning-modal');
            const modalBody = modal.shadowRoot.querySelector('lightning-modal-body');

            const flagFound = modalBody.querySelector('.dynamic-add-overflow-to-modal') != null; // When to use .shadowRoot and when not to is basically trial and error

            // Add the overflow style if the flag was found
            if (flagFound) 
                modalBody.shadowRoot.querySelector('.slds-modal__content').classList.add('c-overflow-visible');
            
        }
    };

    const observer = new MutationObserver((mutations) => {
        // When a lightning-modal-base is added to DOM, check if we need to enable overflow out of modal
        addOverflowIfNeeded();
    });
    
    // Watch page to look out for lightning-overlay-container being added
    observer.observe(
        elem.shadowRoot,
        { 
            attributes: false,
            childList: true,
            characterData: false,
            subtree: true
        }
    );

    addOverflowIfNeeded(); // and run once immediately in case of race condition
}

