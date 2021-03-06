require_relative 'helpers/spec_helper'

feature 'Account' do
  before :each do
    visit '/'
    within '#loginForm' do
      fill_in 'username', with: Helper.TEST_USERNAME
      fill_in 'password', with: Helper.TEST_PASSWORD
    end
    click_button 'Log in'
  end

  scenario 'Looking at your friends' do
    visit '/account/show'
    expect(page).to have_content 'Friends'
    expect(page).to have_content 'User2'
  end

  scenario 'Adding a friend' do
    visit '/explore/find_teammates'
    expect(page).to have_content 'Find new bossing partners'
    click_link 'User8'
    within '#addFriendForm' do
      find('input[type=submit]').click
    end
  end
end
