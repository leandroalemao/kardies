Personality.destroy_all

Chewy.strategy(:atomic) do
  User.destroy_all
end

Chewy.strategy(:atomic) do
  nini = User.create(
    username: 'nini',
    email: 'ni_ni9001@hotmail.com',
    password: 'password',
    confirmed_at: Time.now,
    user_detail_attributes: {
      state: 'att',
      city: 'athina-ATT',
      age: 30,
      gender: 'female'
    }
  )

  100.times do |index|
    u = User.create(
      username: "test_#{index}",
      email: "test_#{index}@test.com",
      password: 'password',
      confirmed_at: Time.now,
      user_detail_attributes: {
        state: 'att',
        city: 'athina-ATT',
        age: 30,
        gender: 'male'
      }
    )

    nini.liked_by u
  end
end

PERSONALITIES.each do |personality|
  Personality.create(
    code: personality.first,
    detail: personality.last
  )
end
