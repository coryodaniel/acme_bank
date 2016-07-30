defmodule BankWeb.TransferControllerTest do
  use BankWeb.ConnCase

  @moduletag isolation: :serializable

  setup do
    :ok = Messenger.Test.setup()
    alice = Bank.create_customer!("alice")
    bob = Bank.create_customer!("bob")
    Bank.create_deposit!(alice, ~M"10 USD")

    conn = assign(build_conn(), :current_customer, alice)

    {:ok, %{conn: conn, alice: alice, bob: bob}}
  end

  test "create: success", %{conn: conn} do
    conn = post conn, "/transfers", %{"transfer" => %{amount_string: "2.01", destination_username: "bob"}}
    assert html_response(conn, 302)
    assert Messenger.Test.subjects_for("bob") == ["You've received $2.01 from alice"]
  end

  test "create: invalid amount", %{conn: conn} do
    conn = post conn, "/transfers", %{"transfer" => %{amount_string: "bad"}}
    assert html_response(conn, 200) =~ "is invalid"
  end
end
