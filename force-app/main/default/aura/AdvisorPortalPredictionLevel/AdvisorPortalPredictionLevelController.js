({
    doInit: function (component) {
        let predictionLevel = component.get('v.predictionLevel');

        if (predictionLevel || predictionLevel === 0) {
            if (predictionLevel >= 0 && predictionLevel <= 3) {
                component.set('v.imageURL', '/icon-1.png');
                component.set('v.alt', 'very low');
                component.set('v.title', 'Very Low');
            } else if (predictionLevel >= 4 && predictionLevel <= 5) {
                component.set('v.imageURL', '/icon-2.png');
                component.set('v.alt', 'low');
                component.set('v.title', 'Low');
            } else if (predictionLevel === 6) {
                component.set('v.imageURL', '/icon-3.png');
                component.set('v.alt', 'moderate');
                component.set('v.title', 'Moderate');
            } else if (predictionLevel === 7) {
                component.set('v.imageURL', '/icon-4.png');
                component.set('v.alt', 'high');
                component.set('v.title', 'High');
            } else if (predictionLevel >= 8 && predictionLevel <= 10) {
                component.set('v.imageURL', '/icon-5.png');
                component.set('v.alt', 'very high');
                component.set('v.title', 'Very High');
            }
        }
    },
});
