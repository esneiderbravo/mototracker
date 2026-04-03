///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAiEn ai = TranslationsAiEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsGarageEn garage = TranslationsGarageEn._(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn._(_root);
	late final TranslationsSharedEn shared = TranslationsSharedEn._(_root);
	late final TranslationsSoatEn soat = TranslationsSoatEn._(_root);
}

// Path: ai
class TranslationsAiEn {
	TranslationsAiEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'AI Autofill'
	String get autofill => 'AI Autofill';

	/// en: 'Search with AI'
	String get searchWithAi => 'Search with AI';

	/// en: 'Yamaha R3 2022'
	String get hintExample => 'Yamaha R3 2022';

	/// en: 'AI error'
	String get error => 'AI error';

	/// en: 'Generating AI insights...'
	String get loadingInsights => 'Generating AI insights...';

	/// en: 'Could not generate insights right now.'
	String get insightsError => 'Could not generate insights right now.';

	/// en: 'No insights available for this motorcycle yet.'
	String get insightsEmpty => 'No insights available for this motorcycle yet.';

	/// en: 'Retry'
	String get retry => 'Retry';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Authentication failed'
	String get error => 'Authentication failed';

	/// en: 'Could not sign in. Check your email and password.'
	String get signInError => 'Could not sign in. Check your email and password.';

	/// en: 'Could not create account. Try a different email.'
	String get signUpError => 'Could not create account. Try a different email.';

	/// en: 'Welcome back'
	String get welcome => 'Welcome back';

	/// en: 'Track, maintain and manage your motorcycles in one premium workspace.'
	String get subtitle => 'Track, maintain and manage your motorcycles in one premium workspace.';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Enter a valid email'
	String get invalidEmail => 'Enter a valid email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Password must be at least 6 characters'
	String get invalidPassword => 'Password must be at least 6 characters';

	/// en: 'Create account'
	String get signUp => 'Create account';

	/// en: 'Sign in'
	String get signIn => 'Sign in';

	/// en: 'Already have an account? Sign in'
	String get haveAccount => 'Already have an account? Sign in';

	/// en: 'No account? Create one'
	String get noAccount => 'No account? Create one';

	/// en: 'Please sign in again.'
	String get signInAgain => 'Please sign in again.';

	/// en: 'Sign out'
	String get signOut => 'Sign out';

	/// en: 'Change password'
	String get changePassword => 'Change password';

	/// en: 'New password'
	String get newPassword => 'New password';

	/// en: 'Confirm password'
	String get confirmPassword => 'Confirm password';

	/// en: 'Passwords do not match'
	String get passwordsDoNotMatch => 'Passwords do not match';

	/// en: 'Password updated successfully.'
	String get passwordChanged => 'Password updated successfully.';

	/// en: 'Could not update password. Please try again.'
	String get passwordChangeError => 'Could not update password. Please try again.';

	/// en: 'Change password'
	String get changePasswordTitle => 'Change password';
}

// Path: garage
class TranslationsGarageEn {
	TranslationsGarageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My Garage'
	String get title => 'My Garage';

	/// en: '${count} bikes'
	String garageCount({required Object count}) => '${count} bikes';

	/// en: 'Your garage is empty'
	String get empty => 'Your garage is empty';

	/// en: 'Add motorcycle'
	String get addMotorcycle => 'Add motorcycle';

	/// en: 'Make'
	String get make => 'Make';

	/// en: 'Model'
	String get model => 'Model';

	/// en: 'Year'
	String get year => 'Year';

	/// en: 'Color'
	String get color => 'Color';

	/// en: 'License plate'
	String get licensePlate => 'License plate';

	/// en: 'Current km'
	String get currentKm => 'Current km';

	/// en: 'Mileage'
	String get mileage => 'Mileage';

	/// en: 'Model year'
	String get modelYear => 'Model year';

	/// en: 'Specifications'
	String get specifications => 'Specifications';

	/// en: 'AI Insights'
	String get aiInsights => 'AI Insights';

	/// en: 'Tips will be available soon.'
	String get aiTipsSoon => 'Tips will be available soon.';

	/// en: 'Danger zone'
	String get dangerZone => 'Danger zone';

	/// en: 'Delete motorcycle'
	String get deleteMotorcycle => 'Delete motorcycle';

	/// en: 'Upload image'
	String get uploadImage => 'Upload image';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Could not save motorcycle. Please try again.'
	String get saveError => 'Could not save motorcycle. Please try again.';

	/// en: 'Motorcycle added successfully.'
	String get saveSuccess => 'Motorcycle added successfully.';

	/// en: 'Motorcycle detail'
	String get motorcycleDetail => 'Motorcycle detail';

	/// en: 'Motorcycle not found'
	String get notFound => 'Motorcycle not found';

	/// en: 'Created'
	String get createdAt => 'Created';

	/// en: 'SOAT coverage'
	String get soatSectionTitle => 'SOAT coverage';

	/// en: 'Check status and manage policy for this bike'
	String get soatSectionSubtitle => 'Check status and manage policy for this bike';

	/// en: 'Open SOAT history'
	String get openSoatHistory => 'Open SOAT history';

	/// en: 'Lookup by plate'
	String get lookupSoatByPlate => 'Lookup by plate';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Are you sure you want to permanently delete ${name}? This action cannot be undone.'
	String deleteConfirmation({required Object name}) => 'Are you sure you want to permanently delete ${name}? This action cannot be undone.';

	/// en: 'No image'
	String get noImage => 'No image';

	/// en: 'Photo'
	String get addPhoto => 'Photo';

	/// en: 'AI autofill failed. Please fill the form manually.'
	String get aiAutofillError => 'AI autofill failed. Please fill the form manually.';
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Pilot profile'
	String get pilotProfile => 'Pilot profile';

	/// en: 'Rider since'
	String get riderSince => 'Rider since';

	/// en: 'Full name'
	String get fullName => 'Full name';

	/// en: 'Mobile phone'
	String get mobilePhone => 'Mobile phone';

	/// en: 'Email address'
	String get emailAddress => 'Email address';

	/// en: 'Your access email is locked for security.'
	String get emailReadOnlyHint => 'Your access email is locked for security.';

	/// en: 'Save changes'
	String get saveChanges => 'Save changes';

	/// en: 'No email'
	String get noEmail => 'No email';

	/// en: 'Keep your bikes, docs and maintenance in sync with Supabase cloud.'
	String get subtitle => 'Keep your bikes, docs and maintenance in sync with Supabase cloud.';

	/// en: 'Profile updated successfully.'
	String get saveSuccess => 'Profile updated successfully.';

	/// en: 'Could not update profile. Please try again.'
	String get saveError => 'Could not update profile. Please try again.';
}

// Path: shared
class TranslationsSharedEn {
	TranslationsSharedEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Garage'
	String get navGarage => 'Garage';

	/// en: 'Profile'
	String get navProfile => 'Profile';

	/// en: 'Required field'
	String get requiredField => 'Required field';

	/// en: 'Enter a valid number'
	String get invalidNumber => 'Enter a valid number';

	/// en: 'Error'
	String get errorLabel => 'Error';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'An unexpected error occurred. Please try again.'
	String get unknownError => 'An unexpected error occurred. Please try again.';
}

// Path: soat
class TranslationsSoatEn {
	TranslationsSoatEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'SOAT'
	String get title => 'SOAT';

	/// en: 'Lookup by plate'
	String get lookup => 'Lookup by plate';

	/// en: 'License Plate'
	String get plate => 'License Plate';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'No active SOAT found for this plate'
	String get notFoundByPlate => 'No active SOAT found for this plate';

	/// en: 'SOAT History'
	String get history => 'SOAT History';

	/// en: 'Add SOAT'
	String get addPolicy => 'Add SOAT';

	/// en: 'No active SOAT for this motorcycle'
	String get noActiveForMotorcycle => 'No active SOAT for this motorcycle';

	/// en: 'Insurer'
	String get insurer => 'Insurer';

	/// en: 'Policy Number'
	String get policyNumber => 'Policy Number';

	/// en: 'Coverage Start'
	String get startDate => 'Coverage Start';

	/// en: 'Expiry Date'
	String get expiryDate => 'Expiry Date';

	/// en: 'Days until expiry'
	String get daysUntilExpiry => 'Days until expiry';

	/// en: 'Expiry date must be after start date'
	String get invalidDateRange => 'Expiry date must be after start date';

	/// en: 'Notes (optional)'
	String get notes => 'Notes (optional)';

	/// en: 'No SOAT policies registered'
	String get empty => 'No SOAT policies registered';

	/// en: 'SOAT saved successfully.'
	String get saveSuccess => 'SOAT saved successfully.';

	/// en: 'Could not save SOAT. Please try again.'
	String get saveError => 'Could not save SOAT. Please try again.';

	/// en: 'Delete this SOAT policy? This action cannot be undone.'
	String get deleteConfirmation => 'Delete this SOAT policy? This action cannot be undone.';

	late final TranslationsSoatStatusesEn statuses = TranslationsSoatStatusesEn._(_root);
}

// Path: soat.statuses
class TranslationsSoatStatusesEn {
	TranslationsSoatStatusesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Due soon (30 days)'
	String get due30 => 'Due soon (30 days)';

	/// en: 'Due in 15 days'
	String get due15 => 'Due in 15 days';

	/// en: 'Due in 5 days'
	String get due5 => 'Due in 5 days';

	/// en: 'Expired'
	String get expired => 'Expired';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'ai.autofill' => 'AI Autofill',
			'ai.searchWithAi' => 'Search with AI',
			'ai.hintExample' => 'Yamaha R3 2022',
			'ai.error' => 'AI error',
			'ai.loadingInsights' => 'Generating AI insights...',
			'ai.insightsError' => 'Could not generate insights right now.',
			'ai.insightsEmpty' => 'No insights available for this motorcycle yet.',
			'ai.retry' => 'Retry',
			'auth.error' => 'Authentication failed',
			'auth.signInError' => 'Could not sign in. Check your email and password.',
			'auth.signUpError' => 'Could not create account. Try a different email.',
			'auth.welcome' => 'Welcome back',
			'auth.subtitle' => 'Track, maintain and manage your motorcycles in one premium workspace.',
			'auth.email' => 'Email',
			'auth.invalidEmail' => 'Enter a valid email',
			'auth.password' => 'Password',
			'auth.invalidPassword' => 'Password must be at least 6 characters',
			'auth.signUp' => 'Create account',
			'auth.signIn' => 'Sign in',
			'auth.haveAccount' => 'Already have an account? Sign in',
			'auth.noAccount' => 'No account? Create one',
			'auth.signInAgain' => 'Please sign in again.',
			'auth.signOut' => 'Sign out',
			'auth.changePassword' => 'Change password',
			'auth.newPassword' => 'New password',
			'auth.confirmPassword' => 'Confirm password',
			'auth.passwordsDoNotMatch' => 'Passwords do not match',
			'auth.passwordChanged' => 'Password updated successfully.',
			'auth.passwordChangeError' => 'Could not update password. Please try again.',
			'auth.changePasswordTitle' => 'Change password',
			'garage.title' => 'My Garage',
			'garage.garageCount' => ({required Object count}) => '${count} bikes',
			'garage.empty' => 'Your garage is empty',
			'garage.addMotorcycle' => 'Add motorcycle',
			'garage.make' => 'Make',
			'garage.model' => 'Model',
			'garage.year' => 'Year',
			'garage.color' => 'Color',
			'garage.licensePlate' => 'License plate',
			'garage.currentKm' => 'Current km',
			'garage.mileage' => 'Mileage',
			'garage.modelYear' => 'Model year',
			'garage.specifications' => 'Specifications',
			'garage.aiInsights' => 'AI Insights',
			'garage.aiTipsSoon' => 'Tips will be available soon.',
			'garage.dangerZone' => 'Danger zone',
			'garage.deleteMotorcycle' => 'Delete motorcycle',
			'garage.uploadImage' => 'Upload image',
			'garage.save' => 'Save',
			'garage.saveError' => 'Could not save motorcycle. Please try again.',
			'garage.saveSuccess' => 'Motorcycle added successfully.',
			'garage.motorcycleDetail' => 'Motorcycle detail',
			'garage.notFound' => 'Motorcycle not found',
			'garage.createdAt' => 'Created',
			'garage.soatSectionTitle' => 'SOAT coverage',
			'garage.soatSectionSubtitle' => 'Check status and manage policy for this bike',
			'garage.openSoatHistory' => 'Open SOAT history',
			'garage.lookupSoatByPlate' => 'Lookup by plate',
			'garage.delete' => 'Delete',
			'garage.deleteConfirmation' => ({required Object name}) => 'Are you sure you want to permanently delete ${name}? This action cannot be undone.',
			'garage.noImage' => 'No image',
			'garage.addPhoto' => 'Photo',
			'garage.aiAutofillError' => 'AI autofill failed. Please fill the form manually.',
			'profile.title' => 'Profile',
			'profile.pilotProfile' => 'Pilot profile',
			'profile.riderSince' => 'Rider since',
			'profile.fullName' => 'Full name',
			'profile.mobilePhone' => 'Mobile phone',
			'profile.emailAddress' => 'Email address',
			'profile.emailReadOnlyHint' => 'Your access email is locked for security.',
			'profile.saveChanges' => 'Save changes',
			'profile.noEmail' => 'No email',
			'profile.subtitle' => 'Keep your bikes, docs and maintenance in sync with Supabase cloud.',
			'profile.saveSuccess' => 'Profile updated successfully.',
			'profile.saveError' => 'Could not update profile. Please try again.',
			'shared.navGarage' => 'Garage',
			'shared.navProfile' => 'Profile',
			'shared.requiredField' => 'Required field',
			'shared.invalidNumber' => 'Enter a valid number',
			'shared.errorLabel' => 'Error',
			'shared.save' => 'Save',
			'shared.edit' => 'Edit',
			'shared.cancel' => 'Cancel',
			'shared.unknownError' => 'An unexpected error occurred. Please try again.',
			'soat.title' => 'SOAT',
			'soat.lookup' => 'Lookup by plate',
			'soat.plate' => 'License Plate',
			'soat.search' => 'Search',
			'soat.notFoundByPlate' => 'No active SOAT found for this plate',
			'soat.history' => 'SOAT History',
			'soat.addPolicy' => 'Add SOAT',
			'soat.noActiveForMotorcycle' => 'No active SOAT for this motorcycle',
			'soat.insurer' => 'Insurer',
			'soat.policyNumber' => 'Policy Number',
			'soat.startDate' => 'Coverage Start',
			'soat.expiryDate' => 'Expiry Date',
			'soat.daysUntilExpiry' => 'Days until expiry',
			'soat.invalidDateRange' => 'Expiry date must be after start date',
			'soat.notes' => 'Notes (optional)',
			'soat.empty' => 'No SOAT policies registered',
			'soat.saveSuccess' => 'SOAT saved successfully.',
			'soat.saveError' => 'Could not save SOAT. Please try again.',
			'soat.deleteConfirmation' => 'Delete this SOAT policy? This action cannot be undone.',
			'soat.statuses.active' => 'Active',
			'soat.statuses.due30' => 'Due soon (30 days)',
			'soat.statuses.due15' => 'Due in 15 days',
			'soat.statuses.due5' => 'Due in 5 days',
			'soat.statuses.expired' => 'Expired',
			_ => null,
		};
	}
}
