const debug = require('debug')('api');
const router = require('express')();
const Joi = require("joi");
const db = require('../storage');

// Set Nickname
router.post('/account/nickname', async (req, res) => {
  debug(req);

  const schema = Joi.object({
    accountIdx: Joi.number().positive().min(1).required(),
    nickname: Joi.string().min(5).max(20).required(),
  });

  try {
    const { error } = schema.validate(req.body);
    if (error) {
      throw { error: 'Invalid Parameter', };
    }

    const { accountIdx, nickname, } = req.body;
    const account = await db.account.get_account(accountIdx);
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
