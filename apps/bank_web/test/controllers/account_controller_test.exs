defmodule BankWeb.AccountControllerTest do
  use BankWeb.ConnCase, async: true

  # test going through HTTP instead of plug will fail
  # use BankWeb.ConnCase, async: false

  @moduletag isolation: :serializable

  test "hey its wellsfargo" do
    Bank.register_customer("alice1", "alice1@example.com", "secret12")
    Bank.register_customer("alice2", "alice2@example.com", "secret12")
    Bank.register_customer("alice3", "alice3@example.com", "secret12")
    Bank.register_customer("alice4", "alice4@example.com", "secret12")

    response = HTTPoison.get!("http://localhost:4001/sign_in")

    assert response.body =~ ~r/alice1/
    assert response.body =~ ~r/alice2/
    assert response.body =~ ~r/alice3/
    assert response.body =~ ~r/alice4/
  end

  test "show", %{conn: conn} do
    {:ok, %{customer: alice}} = Bank.register_customer("alice", "alice@example.com", "secret12")
    Bank.create_deposit!(alice, ~M"10 USD")

    conn = post conn, "/sign_in", %{session: %{email: "alice@example.com", password: "secret12"}}

    conn = get conn, "/account"
    assert conn.status == 200
    assert conn.resp_body =~ "<h2>Account balance</h2>\n\n$10.00"
    assert conn.resp_body =~ "Deposit"
  end

  test "unauthenticated", %{conn: conn} do
    conn = get conn, "/account"
    assert conn.status == 302
  end
end
