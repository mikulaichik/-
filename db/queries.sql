-- Магазин обуви «Лапа»: SQL-запросы для приложения (C#).
-- Знак ? — параметр, который код подставляет из полей формы.
-- Номера в комментариях — пункты чек-листа ДЭ.
USE `lapa_shoes`;

-- =====================================================================
-- 1. ВХОД В ПРИЛОЖЕНИЕ (пункты 2.5, 2.6, 3.17)
--    Пустой результат = неверный логин или пароль.
--    Одна строка = успех: id, ФИО и роль для правого верхнего угла.
-- =====================================================================
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;

-- =====================================================================
-- 2. КАТАЛОГ ТОВАРОВ (пункты 2.7–2.11) — окна гостя, клиента, менеджера, администратора
-- =====================================================================
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s ON s.id = p.supplier_id;

-- =====================================================================
-- 3. ПОИСК, ФИЛЬТР И СОРТИРОВКА (пункты 3.2–3.6) — менеджер и администратор
--    Один запрос; условия включаются независимо и работают вместе.
-- =====================================================================
-- 3.1. Всё вместе: поиск по текстовым полям + поставщик + сортировка по остатку
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s ON s.id = p.supplier_id
WHERE (p.article     LIKE CONCAT('%', ?, '%')
    OR p.name        LIKE CONCAT('%', ?, '%')
    OR p.description LIKE CONCAT('%', ?, '%')
    OR p.unit        LIKE CONCAT('%', ?, '%')
    OR c.name        LIKE CONCAT('%', ?, '%')
    OR m.name        LIKE CONCAT('%', ?, '%')
    OR s.name        LIKE CONCAT('%', ?, '%'))     -- 3.4–3.5: поиск (пустая строка '' находит всё)
  AND (? = 0 OR p.supplier_id = ?)                  -- фильтр; 0 = «Все поставщики»
ORDER BY p.stock_qty DESC;                          -- 3.2: по убыванию; для возрастания — ASC (3.3)

-- 3.2. Только фильтр по поставщику
-- ... WHERE p.supplier_id = ?

-- 3.3. Только сортировка по остатку: убрать WHERE, оставить ORDER BY p.stock_qty ASC|DESC;

-- 3.4. Список поставщиков для выпадающего списка («Все поставщики» код добавляет первым, id = 0)
SELECT id, name FROM suppliers ORDER BY name;

-- =====================================================================
-- 4. ДОБАВЛЕНИЕ И РЕДАКТИРОВАНИЕ ТОВАРА (пункты 3.7, 3.10, 3.12, 3.19)
-- =====================================================================
-- 4.1. Справочники для выпадающих списков формы
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- 4.2. Добавление товара (id присваивает AUTO_INCREMENT: «+1 к имеющемуся»)
INSERT INTO products
  (article, name, unit, price, discount, stock_qty, description, photo,
   category_id, manufacturer_id, supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- 4.3. Открыть товар для редактирования — заполнить все поля формы сразу
SELECT * FROM products WHERE id = ?;

-- 4.4. Сохранить изменения
UPDATE products
SET article=?, name=?, unit=?, price=?, discount=?, stock_qty=?, description=?, photo=?,
    category_id=?, manufacturer_id=?, supplier_id=?
WHERE id = ?;

-- 4.5. Сохранить путь к новому фото (замена изображения, пункт 3.8–3.9)
UPDATE products SET photo = ? WHERE id = ?;

-- =====================================================================
-- 5. УДАЛЕНИЕ ТОВАРА (пункт 3.16 — нельзя удалить товар из заказа)
-- =====================================================================
-- 5.1. Проверка до удаления: > 0 — показать предупреждение «удаление запрещено»
SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = ?;

-- 5.2. Удаление. Если товар есть в заказе, MySQL откажет (ошибка 1451,
--      связь prodorders → products без CASCADE).
DELETE FROM products WHERE id = ?;
