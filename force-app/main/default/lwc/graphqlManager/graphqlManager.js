/**
 * Class for unwrapping GraphQL responses without needing to manually writing out the mapping for every object
 */
export default class GraphqlManager {
    _graphqlData;
    _unwrapped;

    constructor(graphqlData) {
        this._graphqlData = graphqlData;
        this._unwrapped = unwrapGraphQLResponse(graphqlData);
    }

    unwrap() {
        return this._unwrapped;
    }
}

function unwrapGraphQLResponse(response) {
    const result = {};
    const query = response?.uiapi?.query;

    if (!query) return result;

    // eslint-disable-next-line @salesforce/aura/ecma-intrinsics, compat/compat
    for (const [objectType, objectData] of Object.entries(query)) {
        if (!objectData.edges) continue;

        result[objectType] = objectData.edges.map(({node}) => unwrapNode(node));
    }

    return result;
}

function unwrapNode(node) {
    const unwrapped = {};

    // eslint-disable-next-line @salesforce/aura/ecma-intrinsics, compat/compat
    for (const [key, value] of Object.entries(node)) {
        if (value && typeof value === 'object') {
            if ('value' in value) {
                // Basic field with a .value
                unwrapped[key] = value.value;
            } else if (value.edges) {
                // Related list with nested nodes
                // eslint-disable-next-line no-shadow
                unwrapped[key] = value.edges.map(({node}) => unwrapNode(node));
            } else {
                // Related object (like Owner__r), possibly has fields with .value inside
                unwrapped[key] = unwrapNode(value);
            }
        } else {
            // Fallback for primitive or unexpected structures
            unwrapped[key] = value;
        }
    }

    return unwrapped;
}
