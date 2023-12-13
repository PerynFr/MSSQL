SQL Server поддерживает ассиметричные ключи для различных операций, 
таких как шифрование и подпись данных. Однако, напрямую использовать 
ассиметричные ключи для аутентификации запросов (как это делается с SSH-ключами) не предусмотрено.

Однако, вы можете использовать ассиметричные ключи в паре с процедурами хранимыми для реализации 
подобной аутентификации внутри SQL Server. Примерно процесс будет следующим:

1. **Создание ассиметричных ключей:**
   ```sql
   -- Создание ассиметричного ключа
   CREATE ASYMMETRIC KEY MyAsymmetricKey
   WITH ALGORITHM = RSA_2048;
   ```

2. **Создание процедуры хранимой для аутентификации:**
   ```sql
   -- Создание процедуры для аутентификации по ассиметричному ключу
   CREATE PROCEDURE AuthenticateUser
       @PublicKey VARBINARY(MAX),
       @EncryptedCredentials VARBINARY(MAX)
   AS
   BEGIN
       DECLARE @DecryptedCredentials NVARCHAR(MAX);

       -- Расшифровка учетных данных с использованием ассиметричного ключа
       OPEN SYMMETRIC KEY MyAsymmetricKey
       DECRYPTION BY ASYMMETRIC KEY MyAsymmetricKey;

       SELECT @DecryptedCredentials = CONVERT(NVARCHAR(MAX), DecryptByKeyAutoCert(@PublicKey, @EncryptedCredentials));

       CLOSE SYMMETRIC KEY MyAsymmetricKey;

       -- Ваш код проверки учетных данных и возвращение результата аутентификации
       -- ...

   END;
   ```

3. **Использование процедуры для аутентификации:**
   ```sql
   DECLARE @PublicKey VARBINARY(MAX) = -- Здесь передайте публичный ключ пользователя
   DECLARE @EncryptedCredentials VARBINARY(MAX) = -- Здесь передайте зашифрованные учетные данные

   EXEC AuthenticateUser @PublicKey, @EncryptedCredentials;
   ```

это простой пример, и реальная реализация может потребовать дополнительных шагов и усиленной безопасности. 
Это также не полноценная аутентификация через SSH-ключи, но это пример использования ассиметричных ключей для шифрования и 
расшифровки данных в SQL Server.