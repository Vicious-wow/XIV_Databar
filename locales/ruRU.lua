local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "ruRU", false, false);
if not L then return end

L['Modules'] = "Модули";
L['Left-Click'] = "Левая кнопка мыши";
L['Right-Click'] = "Правая кнопка мыши";
L['k'] = "Тыс.";
L['M'] = "Млн.";
L['B'] = "Млрд.";
L['L'] = "Л";
L['W'] = "Г";

-- General
L["Positioning"] = "Позиция";
L['Bar Position'] = "Положение полосы";
L['Top'] = "Вверху";
L['Bottom'] = "Внизу";
L['Bar Color'] = "Цвет полосы";
L['Use Class Color for Bar'] = "Использовать цвет класса для полосы";
L["Miscellaneous"] = "Разное";
L['Hide Bar in combat'] = "Прятать полосу во время боя";
L['Bar Padding'] = "Заполнение";
L['Module Spacing'] = "Расстояние между модулями";
L['Hide order hall bar'] = "Прятать полосу оплота класса";

-- Positioning Options
L['Positioning Options'] = "Настройки позиционированя";
L['Horizontal Position'] = "Позиция по горизонтали";
L['Bar Width'] = "Ширина полосы";
L['Left'] = "Слева";
L['Center'] = "По центру";
L['Right'] = "Справа";

-- Media
L['Font'] = "Шрифт";
L['Small Font Size'] = "Размер маленького шрифта";
L['Text Style'] = "Стиль текста";

-- Text Colors
L["Colors"] = "Цвета";
L['Text Colors'] = "Цвета текста";
L['Normal'] = "Обычный";
L['Inactive'] = "Неактивно";
L["Use Class Color for Text"] = "Использовать цвет класса для текста";
L["Only the alpha can be set with the color picker"] = "В выборе цвета можно указать только прозрачность";
L['Use Class Colors for Hover'] = "Использовать цвет класса при наведении";
L['Hover'] = "По наведению";

-------------------- MODULES ---------------------------

L['Micromenu'] = "Микроменю";
L['Show Social Tooltips'] = "Показывать подсказки гильдии и друзей";
L['Main Menu Icon Right Spacing'] = "Расстояние от кнопки меню до других кнопок";
L['Icon Spacing'] = "Расстояние между кнопками";
L["Hide BNet App Friends"] = true;
L['Open Guild Page'] = "Открыть страницу гильдии";
L['No Tag'] = "Нет Battletag";
L['Whisper BNet'] = "Шепнуть по Battle.Net";
L['Whisper Character'] = "Шепнуть персонажу";
L['Hide Social Text'] = "Скрыть количество онлайна гильдии и друзей";
L["GMOTD in Tooltip"] = "Сообщение дня гильдии в подсказке";
L["Modifier for friend invite"] = "Модификатор для приглашения друзей";
L['Show/Hide Buttons'] = "Показать/скрыть кнопки";
L['Show Menu Button'] = "Меню";
L['Show Chat Button'] = "Выбор чата";
L['Show Guild Button'] = "Гильдия";
L['Show Social Button'] = "Общение";
L['Show Character Button'] = "Информация о персонаже";
L['Show Spellbook Button'] = "Способности";
L['Show Talents Button'] = "Специализация и таланты";
L['Show Achievements Button'] = "Достижения";
L['Show Quests Button'] = "Журнал заданий";
L['Show LFG Button'] = "Поиск группы";
L['Show Journal Button'] = "Путеводитель по приключениям";
L['Show PVP Button'] = "Игрок против игрока";
L['Show Pets Button'] = "Коллекции";
L['Show Shop Button'] = "Магазин";
L['Show Help Button'] = "Помощь";

L['Always Show Item Level'] = "Всегда показывать уровень предметов";
L['Minimum Durability to Become Active'] = "Прочность, до которой загораются цифры";
L['Maximum Durability to Show Item Level'] = "Прочность, после которой показывается уровень предметов";

L['Master Volume'] = "Громкость игры";
L["Volume step"] = "Шаг изменения громкости";

L['Time Format'] = "Формат времени";
L['Use Server Time'] = "Использовать серверное время";
L['New Event!'] = "Новое событие!";
L['Local Time'] = "Местное время";
L['Realm Time'] = "Серверное время";
L['Open Calendar'] = "Открыть календарь";
L['Open Clock'] = "Открыть часы";
L['Hide Event Text'] = "Скрыть текст событий";

L['Travel'] = "Перемещение";
L['Port Options'] = "Назначение телепорта";
L['Ready'] = "Готово";
L['Travel Cooldowns'] = "Способности для перемещения";
L['Change Port Option'] = "Изменить назначение телепорта";

L['Always Show Silver and Copper'] = "Всегда показывать серебро и медь";
L['Shorten Gold'] = "Сокращать число золота";
L['Toggle Bags'] = "Переключить видимость сумок";
L['Session Total'] = "Всего за сессию";
L['Daily Total'] = true;
L['Gold rounded values'] = true;

L['Show XP Bar Below Max Level'] = "Показывать полоску опыта персонажам, не достигшим максимального уровня";
L['Use Class Colors for XP Bar'] = "Использовать цвет класса для полоски опыта";
L['Show Tooltips'] = "Показывать подсказки";
L['Text on Right'] = "Текст справа";
L['Currency Select'] = "Выбор валют";
L['First Currency'] = "Валюта №1";
L['Second Currency'] = "Валюта №2";
L['Third Currency'] = "Валюта №3";
L['Rested'] = "Отдых";

L['Show World Ping'] = "Показывать задержку сервера";
L['Number of Addons To Show'] = "Сколько аддонов показывать";
L['Addons to Show in Tooltip'] = "Сколько аддонов показывать";
L['Show All Addons in Tooltip with Shift'] = "Показывать все аддоны по нажатию кнопки Shift";
L['Memory Usage'] = "Использование памяти";
L['Garbage Collect'] = "Очистить память";
L['Cleaned'] = "Очищено";

L['Use Class Colors'] = "Использовать цвет класса";
L['Cooldowns'] = "Кулдауны";
L['Toggle Profession Frame'] = 'Показать кадр профессии';
L['Toggle Profession Spellbook'] = 'показать книгу заклинаний профессии';

L['Set Specialization'] = "Выбрать специализацию";
L['Set Loot Specialization'] = "Выбрать специализацию для добычи";
L['Current Specialization'] = "Текущая специализация";
L['Current Loot Specialization'] = "Текущая специализация для добычи";
L['Talent Minimum Width'] = "Минимальная ширина модуля талантов";
L['Open Artifact'] = "Открыть меню артефакта";
L['Remaining'] = "Осталось";
L['Available Ranks'] = "Доступно уровней";
L['Artifact Knowledge'] = "Знание артефакта";
