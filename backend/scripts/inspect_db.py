import sqlite3

conn = sqlite3.connect('machhunt_v2.db')
c = conn.cursor()
print("Bookings count:", c.execute("SELECT count(*) FROM bookings").fetchone()[0])
c.execute("SELECT b.id, b.status, u.full_name, m.name, b.seeker_id, b.provider_id FROM bookings b JOIN users u ON b.seeker_id=u.id JOIN machines m ON b.machine_id=m.id LIMIT 10")
for r in c.fetchall():
    print("Booking:", r)

print("\nRequirements count:", c.execute("SELECT count(*) FROM requirements").fetchone()[0])
c.execute("SELECT r.id, r.title, u.full_name, r.status FROM requirements r JOIN users u ON r.user_id=u.id LIMIT 5")
for r in c.fetchall():
    print("Requirement:", r)
