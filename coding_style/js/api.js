const debug = require('debug')('api');
const router = require('express')();
const db = require('../storage');

// Set Nickname
router.post('/account/nickname', async (req, res, next) => {
  debug(req);

  try {
    if(!req.nickname) {
      return next(`Not exist Nickname`);
    }

    const account = await db.account.get_account(req.account_idx);
    if(!account) {
      return next(`Not exist account. req.account_idx: ${req.account_idx}`);
    }

    account.nickname = req.nickname;
    await account.save();
  } catch(err) {
    debug(err);

    return next(`Error : ${err.name}`);
  }

  next();
});

module.exports = router;
