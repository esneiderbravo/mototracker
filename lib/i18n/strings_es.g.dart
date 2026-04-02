///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEs with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAiEs ai = _TranslationsAiEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsGarageEs garage = _TranslationsGarageEs._(_root);
	@override late final _TranslationsProfileEs profile = _TranslationsProfileEs._(_root);
	@override late final _TranslationsSharedEs shared = _TranslationsSharedEs._(_root);
}

// Path: ai
class _TranslationsAiEs implements TranslationsAiEn {
	_TranslationsAiEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get autofill => 'Autorrelleno IA';
	@override String get searchWithAi => 'Buscar con IA';
	@override String get hintExample => 'Yamaha R3 2022';
	@override String get error => 'Error de IA';
}

// Path: auth
class _TranslationsAuthEs implements TranslationsAuthEn {
	_TranslationsAuthEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get error => 'Error de autenticacion';
	@override String get signInError => 'No se pudo iniciar sesion. Verifica tu correo y contraseña.';
	@override String get signUpError => 'No se pudo crear la cuenta. Prueba con otro correo.';
	@override String get welcome => 'Bienvenido';
	@override String get subtitle => 'Gestiona y da mantenimiento a tus motos en un espacio premium.';
	@override String get email => 'Correo';
	@override String get invalidEmail => 'Ingresa un correo valido';
	@override String get password => 'Contraseña';
	@override String get invalidPassword => 'La contraseña debe tener al menos 6 caracteres';
	@override String get signUp => 'Crear cuenta';
	@override String get signIn => 'Iniciar sesion';
	@override String get haveAccount => 'Ya tienes cuenta? Inicia sesion';
	@override String get noAccount => 'No tienes cuenta? Crea una';
	@override String get signInAgain => 'Inicia sesion de nuevo.';
	@override String get signOut => 'Cerrar sesion';
	@override String get changePassword => 'Cambiar contraseña';
	@override String get newPassword => 'Nueva contraseña';
	@override String get confirmPassword => 'Confirmar contraseña';
	@override String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
	@override String get passwordChanged => 'contraseña actualizada correctamente.';
	@override String get passwordChangeError => 'No se pudo actualizar la contraseña. Por favor intenta de nuevo.';
	@override String get changePasswordTitle => 'Cambiar contraseña';
}

// Path: garage
class _TranslationsGarageEs implements TranslationsGarageEn {
	_TranslationsGarageEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mi Garaje';
	@override String garageCount({required Object count}) => '${count} motos';
	@override String get empty => 'Tu garaje esta vacio';
	@override String get addMotorcycle => 'Agregar moto';
	@override String get make => 'Marca';
	@override String get model => 'Modelo';
	@override String get year => 'Año';
	@override String get color => 'Color';
	@override String get licensePlate => 'Placa';
	@override String get currentKm => 'Kilometraje';
	@override String get mileage => 'Kilometraje';
	@override String get modelYear => 'Modelo';
	@override String get specifications => 'Especificaciones';
	@override String get aiInsights => 'AI Insights';
	@override String get aiTipsSoon => 'Los consejos volveran pronto.';
	@override String get dangerZone => 'Zona de peligro';
	@override String get deleteMotorcycle => 'Eliminar moto';
	@override String get uploadImage => 'Subir imagen';
	@override String get save => 'Guardar';
	@override String get saveError => 'No se pudo guardar la moto. Por favor intenta de nuevo.';
	@override String get saveSuccess => 'Moto agregada correctamente.';
	@override String get motorcycleDetail => 'Detalle de moto';
	@override String get notFound => 'Moto no encontrada';
	@override String get createdAt => 'Creado';
	@override String get delete => 'Eliminar';
	@override String get noImage => 'Sin imagen';
	@override String get addPhoto => 'Foto';
	@override String get aiAutofillError => 'El autorrelleno de IA fallo. Por favor completa el formulario manualmente.';
}

// Path: profile
class _TranslationsProfileEs implements TranslationsProfileEn {
	_TranslationsProfileEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Perfil';
	@override String get pilotProfile => 'Perfil del piloto';
	@override String get riderSince => 'Piloto desde';
	@override String get fullName => 'Nombre completo';
	@override String get mobilePhone => 'Telefono movil';
	@override String get emailAddress => 'Correo electronico';
	@override String get emailReadOnlyHint => 'El correo de acceso no es modificable por seguridad.';
	@override String get saveChanges => 'Guardar cambios';
	@override String get noEmail => 'Sin correo';
	@override String get subtitle => 'Manten tus motos, documentos y mantenimientos en la nube de Supabase.';
	@override String get saveSuccess => 'Perfil actualizado correctamente.';
	@override String get saveError => 'No se pudo actualizar el perfil. Por favor intenta de nuevo.';
}

// Path: shared
class _TranslationsSharedEs implements TranslationsSharedEn {
	_TranslationsSharedEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get navGarage => 'Garaje';
	@override String get navProfile => 'Perfil';
	@override String get requiredField => 'Campo requerido';
	@override String get invalidNumber => 'Ingresa un numero valido';
	@override String get errorLabel => 'Error';
	@override String get save => 'Guardar';
	@override String get unknownError => 'Ocurrio un error inesperado. Por favor intenta de nuevo.';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'ai.autofill' => 'Autorrelleno IA',
			'ai.searchWithAi' => 'Buscar con IA',
			'ai.hintExample' => 'Yamaha R3 2022',
			'ai.error' => 'Error de IA',
			'auth.error' => 'Error de autenticacion',
			'auth.signInError' => 'No se pudo iniciar sesion. Verifica tu correo y contraseña.',
			'auth.signUpError' => 'No se pudo crear la cuenta. Prueba con otro correo.',
			'auth.welcome' => 'Bienvenido',
			'auth.subtitle' => 'Gestiona y da mantenimiento a tus motos en un espacio premium.',
			'auth.email' => 'Correo',
			'auth.invalidEmail' => 'Ingresa un correo valido',
			'auth.password' => 'Contraseña',
			'auth.invalidPassword' => 'La contraseña debe tener al menos 6 caracteres',
			'auth.signUp' => 'Crear cuenta',
			'auth.signIn' => 'Iniciar sesion',
			'auth.haveAccount' => 'Ya tienes cuenta? Inicia sesion',
			'auth.noAccount' => 'No tienes cuenta? Crea una',
			'auth.signInAgain' => 'Inicia sesion de nuevo.',
			'auth.signOut' => 'Cerrar sesion',
			'auth.changePassword' => 'Cambiar contraseña',
			'auth.newPassword' => 'Nueva contraseña',
			'auth.confirmPassword' => 'Confirmar contraseña',
			'auth.passwordsDoNotMatch' => 'Las contraseñas no coinciden',
			'auth.passwordChanged' => 'contraseña actualizada correctamente.',
			'auth.passwordChangeError' => 'No se pudo actualizar la contraseña. Por favor intenta de nuevo.',
			'auth.changePasswordTitle' => 'Cambiar contraseña',
			'garage.title' => 'Mi Garaje',
			'garage.garageCount' => ({required Object count}) => '${count} motos',
			'garage.empty' => 'Tu garaje esta vacio',
			'garage.addMotorcycle' => 'Agregar moto',
			'garage.make' => 'Marca',
			'garage.model' => 'Modelo',
			'garage.year' => 'Año',
			'garage.color' => 'Color',
			'garage.licensePlate' => 'Placa',
			'garage.currentKm' => 'Kilometraje',
			'garage.mileage' => 'Kilometraje',
			'garage.modelYear' => 'Modelo',
			'garage.specifications' => 'Especificaciones',
			'garage.aiInsights' => 'AI Insights',
			'garage.aiTipsSoon' => 'Los consejos volveran pronto.',
			'garage.dangerZone' => 'Zona de peligro',
			'garage.deleteMotorcycle' => 'Eliminar moto',
			'garage.uploadImage' => 'Subir imagen',
			'garage.save' => 'Guardar',
			'garage.saveError' => 'No se pudo guardar la moto. Por favor intenta de nuevo.',
			'garage.saveSuccess' => 'Moto agregada correctamente.',
			'garage.motorcycleDetail' => 'Detalle de moto',
			'garage.notFound' => 'Moto no encontrada',
			'garage.createdAt' => 'Creado',
			'garage.delete' => 'Eliminar',
			'garage.noImage' => 'Sin imagen',
			'garage.addPhoto' => 'Foto',
			'garage.aiAutofillError' => 'El autorrelleno de IA fallo. Por favor completa el formulario manualmente.',
			'profile.title' => 'Perfil',
			'profile.pilotProfile' => 'Perfil del piloto',
			'profile.riderSince' => 'Piloto desde',
			'profile.fullName' => 'Nombre completo',
			'profile.mobilePhone' => 'Telefono movil',
			'profile.emailAddress' => 'Correo electronico',
			'profile.emailReadOnlyHint' => 'El correo de acceso no es modificable por seguridad.',
			'profile.saveChanges' => 'Guardar cambios',
			'profile.noEmail' => 'Sin correo',
			'profile.subtitle' => 'Manten tus motos, documentos y mantenimientos en la nube de Supabase.',
			'profile.saveSuccess' => 'Perfil actualizado correctamente.',
			'profile.saveError' => 'No se pudo actualizar el perfil. Por favor intenta de nuevo.',
			'shared.navGarage' => 'Garaje',
			'shared.navProfile' => 'Perfil',
			'shared.requiredField' => 'Campo requerido',
			'shared.invalidNumber' => 'Ingresa un numero valido',
			'shared.errorLabel' => 'Error',
			'shared.save' => 'Guardar',
			'shared.unknownError' => 'Ocurrio un error inesperado. Por favor intenta de nuevo.',
			_ => null,
		};
	}
}
