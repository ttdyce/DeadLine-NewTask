/* eslint-disable semi */
const functions = require("firebase-functions")
const admin = require("firebase-admin")
admin.initializeApp()

const db = admin.firestore()

exports.newUserTrigger = functions.auth.user().onCreate((user) => {
  const email = user.email
  const displayName = user.displayName

  db.collection("users").doc(email).set({})

  functions.logger.info("New user: ", email, "having name", displayName, {
    structuredData: true,
  })
})
