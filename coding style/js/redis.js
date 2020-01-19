const debug = require('debug')('lib:redis');
const bluebird = require('bluebird');
const redis = require('redis');

class Redis {
	constructor(opts, subscribe_func = () => {}, init_func_list = []) {
		this.opts = opts;
		this.client = redis.createClient(opts.endPoint);
		this.client = bluebird.promisifyAll(this.client);
		this.subscribe_func = subscribe_func;

		const init_func_list_ = init_func_list;
		this.client.on('connect', () => {
			debug(`Redis ${this.opts.name} : connected`);

			this.init_sub_channel();

			init_func_list_.forEach(async (redis_job) => {
				if(redis_job.name != this.opts.name) { return; }
				await redis_job.run_func(this.client);
			});
		});

		this.client.on('error', (err) => {
			debug(`Redis ${this.opts.name} err : ${err}`);
		});

		this.client.on('reconnecting', () => {
			debug(`Redis ${this.opts.name} : reconnecting Redis`);
		});

		this.client.on('message', (channel, message) => {
			this.subscribe_func(channel, message);
		});
	}

	init_sub_channel() {
		this.opts.subChannel.map(channel_name => {
			this.client.subscribe(channel_name);
		});
	}

	getConnection() {
		return this.client;
	}
}

module.exports = Redis;

