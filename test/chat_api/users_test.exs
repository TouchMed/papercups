defmodule ChatApi.UsersTest do
  use ChatApi.DataCase, async: true
  @moduledoc false

  import ChatApi.Factory

  alias ChatApi.Users
  alias ChatApi.Users.{User, UserProfile, UserSettings}

  describe "user_profiles" do
    @valid_attrs %{
      display_name: "some display_name",
      full_name: "some full_name",
      profile_photo_url: "some profile_photo_url"
    }
    @update_attrs %{
      display_name: "some updated display_name",
      full_name: "some updated full_name",
      profile_photo_url: "some updated profile_photo_url"
    }

    setup do
      {:ok, user: insert(:user)}
    end

    test "set_admin_role/1 sets the user's role to 'admin'", %{user: user} do
      assert {:ok, %User{role: "admin"}} = Users.set_admin_role(user)
    end

    test "set_user_role/1 sets the user's role to 'user'", %{user: user} do
      assert {:ok, %User{role: "user"}} = Users.set_user_role(user)
    end

    test "disable_user/1 disables the user", %{user: user} do
      assert {:ok, %User{disabled_at: disabled_at}} = Users.disable_user(user)
      assert disabled_at != nil
    end

    test "archive_user/1 archives the user", %{user: user} do
      assert {:ok, %User{archived_at: archived_at}} = Users.archive_user(user)
      assert archived_at != nil
    end

    test "get_user_profile/1 returns the user_profile with given valid user id",
         %{user: user} do
      assert %UserProfile{user_id: id} = Users.get_user_profile(user.id)

      assert id == user.id
    end

    test "update_user_profile/2 with valid data updates the user_profile",
         %{user: user} do
      assert {:ok, %UserProfile{} = user_profile} =
               Users.update_user_profile(user.id, @valid_attrs)

      assert user_profile.display_name == @valid_attrs.display_name

      assert {:ok, %UserProfile{} = user_profile} =
               Users.update_user_profile(user.id, @update_attrs)

      assert user_profile.display_name == @update_attrs.display_name
    end

    test "get_user_profile/1 and Users.get_user_settings/1 get the profile and settings",
         %{user: user} do
      assert %UserProfile{} = Users.get_user_profile(user.id)
      assert %UserSettings{} = Users.get_user_settings(user.id)
    end
  end

  describe "emails" do
    @company_name "Test Inc"

    setup do
      account = insert(:account, company_name: @company_name)
      user = insert(:user, account: account)

      {:ok, account: account, user: user}
    end

    test "Emails.format_sender_name/1 returns the company name when no profile is set",
         %{account: account, user: user} do
      user = Users.get_user_info(user.id)

      refute user.profile
      assert "Test Inc" = ChatApi.Emails.format_sender_name(user, account)
    end

    test "Emails.format_sender_name/1 returns the company name when no display_name or full_name are set",
         %{account: account, user: user} do
      assert {:ok, %UserProfile{}} =
               Users.update_user_profile(user.id, %{display_name: nil, full_name: nil})

      user = Users.get_user_info(user.id)

      assert "Test Inc" = ChatApi.Emails.format_sender_name(user, account)
    end

    test "Emails.format_sender_name/1 prioritizes the display_name if both display_name and full_name are set",
         %{account: account, user: user} do
      assert {:ok, %UserProfile{}} =
               Users.update_user_profile(user.id, %{display_name: "Alex", full_name: "Alex R"})

      user = Users.get_user_info(user.id)

      assert "Alex" = ChatApi.Emails.format_sender_name(user, account)

      assert {:ok, %UserProfile{}} =
               Users.update_user_profile(user.id, %{display_name: nil, full_name: "Alex R"})

      user = Users.get_user_info(user.id)

      assert "Alex R" = ChatApi.Emails.format_sender_name(user, account)

      assert {:ok, %UserProfile{}} =
               Users.update_user_profile(user.id, %{display_name: "Alex", full_name: nil})

      user = Users.get_user_info(user.id)

      assert "Alex" = ChatApi.Emails.format_sender_name(user, account)
    end
  end

  describe "user_settings" do
    @valid_attrs %{email_alert_on_new_message: true}
    @update_attrs %{email_alert_on_new_message: false}

    setup do
      {:ok, user: insert(:user)}
    end

    test "get_user_settings/1 returns the user_settings with given valid user id", %{user: user} do
      %UserSettings{user_id: user_id} = Users.get_user_settings(user.id)

      assert user_id == user.id
    end

    test "update_user_settings/2 with valid data updates the user_settings",
         %{user: user} do
      assert {:ok, %UserSettings{} = user_settings} =
               Users.update_user_settings(user.id, @valid_attrs)

      assert user_settings.email_alert_on_new_message == true

      assert {:ok, %UserSettings{} = user_settings} =
               Users.update_user_settings(user.id, @update_attrs)

      assert user_settings.email_alert_on_new_message == false
    end
  end
end
