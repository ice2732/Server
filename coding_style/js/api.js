const debug = require('debug')('api');
const router = require('express')();
const db = require('../storage');

// Set Nickname
router.post('/account/nickname', async (req, res) => {
  debug(req);

  try {
    const { account_idx, nickname, } = req;
    if(!nickname) {
      throw { error: 'Invalid Nickname', };
    }

    const account = await db.account.get_account(account_idx);
    if(!account) {
      throw { error: 'Not exist account', };
    }

    account.nickname = nickname;
    await account.save();
    res.ok();
  } catch(err) {
    debug(err);
    res.error(err.error);
  }
});

module.exports = router;
