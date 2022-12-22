/**
 * Loads all dependencies for Lightning Out and adds the LWC to the DOM
 * @param {string} auraApp Name of the Aura app that contains the LWC
 * @param {string} lwcName Name of the LWC
 * @param {object} params Params for the LWC
 * @param {function} cb Callback to run after LWC is attached to the DOM 
 */
function createLWC(auraApp, lwcName, params, cb) {
    console.log('Creating LWC', auraApp, lwcName, params, cb);
    if (verifyAuraApp(auraApp)) {
        createLoader();
        incrementLoader();
        verifyLwcQueue();
        appendToLwcQueue(auraApp, lwcName, params, cb);
        loadJSRequirementsAndAddLwcs();
    } else {
        console.error('Cannot add LWC from Aura app: "' + auraApp + '" since already has loaded Aura app: "' + window.$AuraApp + '"');
    }
 
}

/**
 * You can only load one Aura app per page - this function checks if the Aura app that you are trying to load
 * matches the loaded Aura app (or if it is the first Aura app attempted to be loaded)
 * @param {string} desiredAuraApp 
 * @returns True if the desired Aura app matches the existing Aura app or if it is the first Aura app specified on the page
 */
function verifyAuraApp(desiredAuraApp) {
    if (!window.hasOwnProperty('$AuraApp')) {
        window.$AuraApp = desiredAuraApp;
    }

    return window.$AuraApp === desiredAuraApp;
}

/**
 * Creates the $LwcQueue window property if one is not yet defined.  This should contain all LWCs that need to be loaded after the required
 * dependencies are ready
 */
function verifyLwcQueue() {
    if (!window.hasOwnProperty('$LwcQueue')) {
        window.$LwcQueue = [];
    }
}

/**
 * A description of a LWC that needs to be loaded.  Every element in $LwcQueue should be an instance of this class
 */
class LWCQueueElement {
    auraApp;
    lwcName;
    params;
    cb;

    constructor() {}
}

/**
 * Create a LWCQueueElement for this LWC and add it to the $LwcQueue
 * @param {string} auraApp The name of the Aura app that contains the LWC
 * @param {string} lwcName The name of the LWC
 * @param {object} params Params to pass to the LWC
 * @param {function} cb A callback function to run after the LWC has been attached to the DOM
 */
function appendToLwcQueue(auraApp, lwcName, params, cb) {
    const queueElem = {
        auraApp, lwcName, params, cb
    };
    queueElem.auraApp = auraApp;
    queueElem.lwcName = lwcName;
    queueElem.params = params;
    queueElem.cb = cb;

    window.$LwcQueue.push(queueElem);
}

/**
 * Loads the Lightning Out dependency if needed, and after the dependency is ready, adds each LWC in the $LwcQueue
 */
function loadJSRequirementsAndAddLwcs() {
    if (!window.hasOwnProperty('$Lightning')) { 
        let documentHead = document.querySelector('head');
        let lightningJS = document.createElement('script');
        
        lightningJS.setAttribute('onload', 'initLightningAndAddLwcs()');
        lightningJS.src = '/lightning/lightning.out.js';
        documentHead.appendChild(lightningJS);
    } else {
        initLightningAndAddLwcs();
    }
}

/**
 * Adds each element in $LwcQueue to the page
 */
function initLightningAndAddLwcs() {
    // Load the Aura app
    $Lightning.use(
        window.$AuraApp,
        // Once Aura app is loaded, for each LWC in the queue, attach it to the DOM
        () => {
            while (window.$LwcQueue.length > 0) {
                const lwcQueueElem = window.$LwcQueue.pop();

                // Add div to attach the LWC to
                const documentBody = document.querySelector('body');
                const wrapper = document.createElement('div');
                wrapper.id = randomId();
                documentBody.appendChild(wrapper);

                // Create the LWC
                $Lightning.createComponent(
                    lwcQueueElem.lwcName,
                    lwcQueueElem.params,
                    wrapper.id,
                    (cmp) => {
                        decrementLoader();
                        lwcQueueElem.cb(cmp);
                    }
                );
            }
        }
    );
}

/**
 * base64 encodes a string generated using Math.random() so that it can return a random string
 * @returns a random base64 string
 */
function randomId() {
    return btoa(Math.random()+'');
}

function createLoader() {
	if (!document.querySelector('.lightning-loader')) {
		const documentBody = document.querySelector('body');

        const spinnerDiv = document.createElement('div');
        spinnerDiv.classList.add('slds-spinner');
        spinnerDiv.classList.add('slds-spinner_medium');
        spinnerDiv.classList.add('slds-spinner_inverse');
        spinnerDiv.role = 'status';
        spinnerDiv.innerHTML='<span class="slds-assistive-text">Loading</span><div class="slds-spinner__dot-a"></div><div class="slds-spinner__dot-b"></div>';

 		const spinnerWrapper = document.createElement('div');
        spinnerWrapper.classList.add('lightning-loader');
        spinnerWrapper.classList.add('slds-scope');
		spinnerWrapper.style = 'display:none; position:fixed; left:0px; top:0px; width:100%; height:100%; background:rgba(126,140,153,0.8); z-index:9500;';
        spinnerWrapper.appendChild(spinnerDiv);
		
		documentBody.appendChild(spinnerWrapper);
	}
}


function incrementLoader() {
    verifyLoadingCounter();
    window.$LWCLoadingCounter += 1;
    updateLoaderBasedOnCounter();
}

function decrementLoader() {
    verifyLoadingCounter();
    window.$LWCLoadingCounter -= 1;
    updateLoaderBasedOnCounter();
}

function verifyLoadingCounter() {
    if (!window.hasOwnProperty('$LWCLoadingCounter')) {
        window.$LWCLoadingCounter = 0;
    }
}

function updateLoaderBasedOnCounter() {
	let loader = document.querySelector('.lightning-loader');
    
    if (window.$LWCLoadingCounter > 0) {
        loader.style.display = 'block';
    } else {
        window.$LWCLoadingCounter = 0;
        loader.style.display = 'none';
    }

}

