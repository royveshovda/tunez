defmodule TunezWeb.JsonApi.UserTest do
  use TunezWeb.ConnCase, async: true

  import AshJsonApi.Test

  test "can sign in to an existing account" do
    generate(user(email: "one@example.com", password: "password"))

    response =
      post(
        Tunez.Accounts,
        "/users/sign-in",
        %{
          data: %{attributes: %{email: "one@example.com", password: "password"}}
        },
        router: TunezWeb.AshJsonApiRouter,
        status: 201
      )

    assert response.resp_body["meta"]["token"] != nil
  end

  test "can register a new account" do
    response =
      post(
        Tunez.Accounts,
        "/users/register",
        %{
          data: %{
            attributes: %{
              email: "one@example.com",
              password: "password",
              password_confirmation: "password"
            }
          }
        },
        router: TunezWeb.AshJsonApiRouter,
        status: 201
      )

    assert response.resp_body["meta"]["token"] != nil
  end
end
