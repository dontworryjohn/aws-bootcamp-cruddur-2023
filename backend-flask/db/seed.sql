-- this file was manually created
INSERT INTO public.users (display_name,email, handle, cognito_user_id)
VALUES
  ('john carlos buen','johncarlos.buen@gmail.com', 'dontworryjohn' ,'a901d29f-dfb2-4cdd-b14e-8d367e8048d7'),
  ('john b','ohnojay_z@hotmail.it', 'ohnojohn' ,'d00f9c33-d33f-40b6-a6b4-fab3f4824972'),
  ('Londo Mollari','lmollari@centari.com', 'londo' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'dontworryjohn' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )
