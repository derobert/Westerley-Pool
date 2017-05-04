-- This creates a sample administrator. You should log in and either
-- create your own admin, or at least change the password!
--
-- username: admin
-- password: admin
INSERT INTO users (user_name, user_pwhash) VALUES
	('admin', '$2a$14$......................IqPfDXMr29Wlzg8ytj9sKZ0/l90OJa2')
	;

INSERT INTO user_roles (user_num, role_num) VALUES
	(
		(SELECT user_num FROM users WHERE user_name = 'admin'),
		(SELECT role_num FROM roles WHERE role_name = 'admin')
	),
	(
		(SELECT user_num FROM users WHERE user_name = 'admin'),
		(SELECT role_num FROM roles WHERE role_name = 'backup')
	)
	(
		(SELECT user_num FROM users WHERE user_name = 'admin'),
		(SELECT role_num FROM roles WHERE role_name = 'documents')
	)
	;
	
