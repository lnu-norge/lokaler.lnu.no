# frozen_string_literal: true

class AddRememberTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    # Needed for https://github.com/devise-passwordless/devise-passwordless/tree/master
    change_table :users do |t|
      t.string :remember_token, limit: 20
    end
  end
end
