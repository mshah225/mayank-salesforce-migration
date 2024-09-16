/* eslint-disable no-undef */
import GqlParserMock from 'c/gqlParserMock';

describe('c-gql-parser-mock', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Parse simple tree', () => {
        const queryStr = `
            query {
                uiapi {
                    query {
                        Case {
                            edges {
                                node {
                                    Subject {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse multiple branch query', () => {
        const queryStr = `
            query {
                uiapi {
                    query {
                        Case {
                            edges {
                                node {
                                    Contact {
                                        Name {
                                            value
                                        }
                                    }
                                    Id
                                    Subject {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Id: null,
                                    Subject: {
                                        value: null,
                                    },
                                    Contact: {
                                        Name: {
                                            value: null,
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse same-line simple attribute', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(first: 2000) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                first: '2000',
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse same-line deep attribute', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(where: {Id: {eq: $recordId}}) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                where: {Id: {eq: '$recordId'}},
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse same-line multiple attributes', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(first: 2000, where: {Id: {eq: $recordId}}) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                first: '2000',
                                where: {Id: {eq: '$recordId'}},
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse same-line complex attribute', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(where: {and: [{IsClosed: {eq:false}}, {Visible__c: {eq: true}}]}) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                where: {
                                    and: [{IsClosed: {eq: 'false'}}, {Visible__c: {eq: 'true'}}],
                                },
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse multi-line simple attribute', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(first: 
                        2000
                    ) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                first: '2000',
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse multi-line deep attribute', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(where: {
                        Id: {
                            eq: $recordId
                        }
                    }) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                where: {Id: {eq: '$recordId'}},
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse multi-line multiple attributes', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(
                        first: 2000
                        where: {
                            Id: {
                                eq: $recordId
                            }
                        }
                    ) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                first: '2000',
                                where: {Id: {eq: '$recordId'}},
                            },
                        },
                    },
                },
            },
        });
    });

    test('Parse multi-line complex attribute', () => {
        const queryStr = `
        query {
            uiapi {
                query {
                    Case(
                        where: {
                            and: [
                                {IsClosed: {eq:false}}
                                {Visible__c: {eq: true}}
                            ]
                        }
                    ) {
                        edges {
                            node {
                                Subject {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            query: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                            __attribs: {
                                where: {
                                    and: [{IsClosed: {eq: 'false'}}, {Visible__c: {eq: 'true'}}],
                                },
                            },
                        },
                    },
                },
            },
        });
    });

    test('Extracts query name', () => {
        const queryStr = `
                query CaseQuery {
                    uiapi {
                        query {
                            Case {
                                edges {
                                    node {
                                        Subject {
                                            value
                                        }
                                    }
                                }
                            }
                        }
                    }
                }`;
        let parser = new GqlParserMock(queryStr);

        expect(parser.object).toEqual({
            CaseQuery: {
                uiapi: {
                    query: {
                        Case: {
                            edges: {
                                node: {
                                    Subject: {
                                        value: null,
                                    },
                                },
                            },
                        },
                    },
                },
            },
        });
    });
});
