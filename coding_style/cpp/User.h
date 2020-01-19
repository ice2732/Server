#pragma once

#include <algorithm>
#include <iostream>
#include <memory>
#include <vector>

using index_user_t = uint64_t;
const uint32_t MAX_ITEM_AMOUNT = 999;

class Item
{
public:
	Item(const uint32_t item_id, const int32_t amount = 0) : item_id_(item_id), amount_(amount) {}
	~Item() {}

public:
	bool add(const int32_t amount)
	{
		if (MAX_ITEM_AMOUNT < (amount_ + amount))
			return false;

		amount_ += amount;
		return true;
	}

	inline const uint32_t	get_item_id() const { return item_id_; }
	inline const int32_t	get_amount() const { return amount_; }

private:
	uint32_t				item_id_;
	int32_t					amount_;
};

class User
{
public:
	User(const index_user_t user_idx) : user_idx_(user_idx) {}
	~User() {}

public:
	bool add_item(const uint32_t item_id, const int32_t amount)
	{
		auto it_item = std::find_if(items_.begin(), items_.end(), [=](const Item& item) {
			if (item.get_item_id() == item_id)
				return true;

			return false;
			});

		if (items_.end() == it_item)
		{
			items_.emplace_back(item_id, amount);
			return true;
		}

		return it_item->add(amount);
	}

	void print_item_list()
	{
		for (const auto& item : items_)
		{
			std::cout << item.get_item_id() << ": " << item.get_amount() << std::endl;
		}
	}

private:
	index_user_t			user_idx_;
	std::vector<Item>		items_;
};

int main()
{
	const index_user_t user_idx = 1;
	std::shared_ptr<User> user = std::make_shared<User>(user_idx);
	user->add_item(1000, 10);
	user->add_item(2000, 20);
	user->add_item(3000, 30);
	user->print_item_list();

	return 0;
}
