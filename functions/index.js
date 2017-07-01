let functions = require('firebase-functions');
let admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.sendPush = functions.database.ref('/messages/{messageId}').onWrite(event => {

    let messageStateChanged = false;
    let messageCreated = false;
    let messageData = event.data.val();

    if (!event.data.previous.exists()) {

        messageCreated = true;
    }
    if (!messageCreated && event.data.changed()) {

        messageStateChanged = true;
    }

    let msg = 'You have received a message.';

		if (messageCreated) {

			msg = `${messageData.text}`;
		}

    return loadUsers().then(users => {

        let tokens = [];
        for (let user of users) {
            tokens.push(user.pushToken);
        }
        let payload = {
            notification: {
                title: 'New Event Message',
                body: msg,
                sound: 'default',
                badge: '1'
            }
        };
        return admin.messaging().sendToDevice(tokens, payload);
    });
});

function loadUsers() {

    let dbRef = admin.database().ref('/users');
    let defer = new Promise((resolve, reject) => {
        dbRef.once('value', (snap) => {
            let data = snap.val();
            let users = [];
            for (var property in data) {
                users.push(data[property]);
            }
            resolve(users);
        }, (err) => {
            reject(err);
        });
    });
    return defer;
}