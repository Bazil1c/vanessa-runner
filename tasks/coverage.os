#Использовать 1commands
#Использовать asserts
#Использовать fs
#Использовать json

КаталогФайловПокрытия = ОбъединитьПути(ТекущийКаталог(), ".", "coverage");
ФС.ОбеспечитьПустойКаталог(КаталогФайловПокрытия);

ПутьКСтат = ОбъединитьПути(КаталогФайловПокрытия, "stat.json");


Команда = Новый Команда;
Команда.УстановитьКоманду("oscript");
Команда.ПоказыватьВыводНемедленно(Истина);
// Команда.ДобавитьПараметр("-encoding=utf-8");
Команда.ДобавитьПараметр(СтрШаблон("-codestat=%1", ПутьКСтат));    
Команда.ДобавитьПараметр("tasks/test.os");    

КодВозврата = Команда.Исполнить();
Сообщить(Команда.ПолучитьВывод());
// Ожидаем.Что(КодВозврата).Равно(0);

ЗаписьXML = Новый ЗаписьXML;
ЗаписьXML.ОткрытьФайл("coverage/genericCoverage.xml");
ЗаписьXML.ЗаписатьОбъявлениеXML();
ЗаписьXML.ЗаписатьНачалоЭлемента("coverage");
ЗаписьXML.ЗаписатьАтрибут("version", "1");

МассивФайлов = НайтиФайлы(КаталогФайловПокрытия, "*.json");
Для каждого ФайлСтатистики Из МассивФайлов Цикл
	ПутьКСтат = ФайлСтатистики.ПолноеИмя;
	Файл_Стат = Новый Файл(ПутьКСтат);
	Ожидаем.Что(Файл_Стат.Существует(), СтрШаблон("Файл <%1> с результатами покрытия не существует!", Файл_Стат.ПолноеИмя)).ЭтоИстина();
	
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКСтат, КодировкаТекста.UTF8);
	
	СтрокаJSON = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	Парсер = Новый ПарсерJSON();
	ДанныеПокрытия = Парсер.ПрочитатьJSON(СтрокаJSON);
	
	Для Каждого Файл Из ДанныеПокрытия Цикл

		ДанныеФайла = Файл.Значение;
		
		ЗаписьXML.ЗаписатьНачалоЭлемента("file");
		ЗаписьXML.ЗаписатьАтрибут("path", ДанныеФайла.Получить("#path"));
		
		Для Каждого КлючИЗначение Из ДанныеФайла Цикл
			
			Если КлючИЗначение.Ключ = "#path" Тогда
				Продолжить;
			КонецЕсли;
			
			ДанныеПроцедуры = КлючИЗначение.Значение;
			Для Каждого ДанныеСтроки Из ДанныеПроцедуры Цикл
				
				ЗаписьXML.ЗаписатьНачалоЭлемента("lineToCover");
				
				ЗаписьXML.ЗаписатьАтрибут("lineNumber", ДанныеСтроки.Ключ);
				Покрыто = Число(ДанныеСтроки.Значение.Получить("count")) > 0;
				ЗаписьXML.ЗаписатьАтрибут("covered", Формат(Покрыто, "БИ=true; БЛ=false"));
				
				ЗаписьXML.ЗаписатьКонецЭлемента(); // lineToCover
			КонецЦикла
		КонецЦикла;
	
		ЗаписьXML.ЗаписатьКонецЭлемента(); // file
	КонецЦикла;


КонецЦикла;

ЗаписьXML.ЗаписатьКонецЭлемента(); // coverage
ЗаписьXML.Закрыть();