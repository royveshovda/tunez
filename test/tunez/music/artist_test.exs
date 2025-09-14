defmodule Tunez.Music.ArtistTest do
  use Tunez.DataCase, async: true

  alias Tunez.Music, warn: false

  describe "Tunez.Music.read_artists!/0-2" do
    test "when there is no data, nothing is returned" do
      assert Music.read_artists!() == []
    end
  end

  describe "Tunez.Music.search_artists/1-2" do
    def names(page), do: Enum.map(page.results, & &1.name)

    test "can filter by partial name matches" do
      ["hello", "goodbye", "what?"]
      |> Enum.each(&generate(artist(name: &1)))

      assert Enum.sort(names(Music.search_artists!("o"))) == ["goodbye", "hello"]
      assert names(Music.search_artists!("oo")) == ["goodbye"]
      assert names(Music.search_artists!("he")) == ["hello"]
    end

    test "can sort by name" do
      ["first", "third", "fourth", "second"]
      |> Enum.each(&generate(artist(name: &1)))

      actual = names(Music.search_artists!("", query: [sort_input: "+name"]))
      assert actual == ["first", "fourth", "second", "third"]
    end

    test "can sort by creation time" do
      generate(artist(seed?: true, name: "first", inserted_at: ago(30, :second)))
      generate(artist(seed?: true, name: "third", inserted_at: ago(10, :second)))
      generate(artist(seed?: true, name: "second", inserted_at: ago(20, :second)))

      actual = names(Music.search_artists!("", query: [sort_input: "-inserted_at"]))
      assert actual == ["third", "second", "first"]
    end

    test "can sort by update time" do
      generate(artist(seed?: true, name: "first", updated_at: ago(30, :second)))
      generate(artist(seed?: true, name: "third", updated_at: ago(10, :second)))
      generate(artist(seed?: true, name: "second", updated_at: ago(20, :second)))

      actual = names(Music.search_artists!("", query: [sort_input: "-updated_at"]))
      assert actual == ["third", "second", "first"]
    end

    test "can sort by latest album release" do
      first = generate(artist(name: "first"))
      generate(album(year_released: 2023, artist_id: first.id))

      third = generate(artist(name: "third"))
      generate(album(year_released: 2008, artist_id: third.id))

      second = generate(artist(name: "second"))
      generate(album(year_released: 2012, artist_id: second.id))

      actual =
        names(Music.search_artists!("", query: [sort_input: "--latest_album_year_released"]))

      assert actual == ["first", "second", "third"]
    end

    test "can sort by number of album releases" do
      generate(artist(name: "two", album_count: 2))
      generate(artist(name: "none"))
      generate(artist(name: "one", album_count: 1))
      generate(artist(name: "three", album_count: 3))

      actual =
        names(Music.search_artists!("", query: [sort_input: "-album_count"]))

      assert actual == ["three", "two", "one", "none"]
    end

    test "can paginate search results" do
      generate_many(artist(), 2)

      page = Music.search_artists!("", page: [limit: 1])
      assert length(page.results) == 1
      assert page.more?

      next_page = Ash.page!(page, :next)
      assert length(page.results) == 1
      refute next_page.more?
    end
  end

  describe "Tunez.Music.create_artist/1-2" do
    test "stores the actor that created the record" do
      actor = generate(user(role: :admin))

      artist = Music.create_artist!(%{name: "New Artist"}, actor: actor)
      assert artist.created_by_id == actor.id
      assert artist.updated_by_id == actor.id
    end
  end

  describe "Tunez.Music.update_artist/2-3" do
    test "collects old names when the artist name changes" do
      actor = generate(user(role: :admin))

      artist = generate(artist(name: "First Name"))
      assert artist.previous_names == []

      # First Name is moved to previous_names
      artist = Music.update_artist!(artist, %{name: "Second Name"}, actor: actor)
      assert artist.previous_names == ["First Name"]

      # Second Name is added to previous names
      artist = Music.update_artist!(artist, %{name: "Third Name"}, actor: actor)
      assert artist.previous_names == ["Second Name", "First Name"]

      # First Name is now the current name again, not a previous name
      artist = Music.update_artist!(artist, %{name: "First Name"}, actor: actor)
      assert artist.previous_names == ["Third Name", "Second Name"]
    end

    test "stores the actor that updated the record" do
      actor = generate(user(role: :admin))

      artist = generate(artist(name: "First Name"))
      refute artist.updated_by_id == actor.id

      artist = Music.update_artist!(artist, %{name: "Second Name"}, actor: actor)
      assert artist.updated_by_id == actor.id
    end
  end

  describe "Tunez.Music.destroy_artist/2" do
    @tag skip: "can be enabled during chapter 10"
    test "deletes any associated albums when the artist is deleted" do
      # artist = generate(artist())
      # album = generate(album(artist_id: artist.id, name: "to be deleted"))

      # # This should be deleted too, without error
      # notification = generate(notification(album_id: album.id))

      # Music.destroy_artist!(artist, authorize?: false)

      # refute get_by_name(Tunez.Music.Album, "to be deleted")
      # assert match?({:error, _}, Ash.get(Tunez.Accounts.Notification, notification.id))
    end
  end

  describe "cover_image_url" do
    test "uses the cover from the first album that has a cover" do
      artist = generate(artist())
      generate(album(artist_id: artist.id, year_released: 2021))

      generate(
        album(
          artist_id: artist.id,
          year_released: 2019,
          cover_image_url: "/images/older.jpg"
        )
      )

      generate(
        album(
          artist_id: artist.id,
          year_released: 2020,
          cover_image_url: "/images/the_real_cover.png"
        )
      )

      {:ok, artist} = Ash.load(artist, :cover_image_url)
      assert artist.cover_image_url == "/images/the_real_cover.png"
    end
  end

  describe "policies" do
    def setup_users do
      %{
        admin: generate(user(role: :admin)),
        editor: generate(user(role: :editor)),
        user: generate(user(role: :user))
      }
    end

    test "only admins can create new artists" do
      users = setup_users()

      assert Music.can_create_artist?(users.admin)
      refute Music.can_create_artist?(users.editor)
      refute Music.can_create_artist?(users.user)
      refute Music.can_create_artist?(nil)
    end

    test "only admins can delete artists" do
      users = setup_users()
      artist = generate(artist())

      assert Music.can_destroy_artist?(users.admin, artist)
      refute Music.can_destroy_artist?(users.editor, artist)
      refute Music.can_destroy_artist?(users.user, artist)
      refute Music.can_destroy_artist?(nil, artist)
    end

    test "admins and editors can update artists" do
      users = setup_users()
      artist = generate(artist())

      assert Music.can_update_artist?(users.admin, artist)
      assert Music.can_update_artist?(users.editor, artist)
      refute Music.can_update_artist?(users.user, artist)
      refute Music.can_update_artist?(nil, artist)
    end
  end
end
