// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Rastreador de Casos USCIS';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInSubtitle => 'Inicia sesión para rastrear tus casos en USCIS';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get signUp => 'Registrarse';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio';

  @override
  String get emailInvalid => 'Ingresa un correo electrónico válido';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get createAccountSubtitle => 'Comienza a rastrear tus casos en USCIS';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordMinLength => 'Mínimo 8 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get fullNameRequired => 'El nombre completo es obligatorio';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get myCases => 'Mis Casos';

  @override
  String hello(String name) {
    return 'Hola, $name';
  }

  @override
  String get noCasesYet => 'Sin casos aún';

  @override
  String get noCasesSubtitle =>
      'Agrega tus números de recibo de USCIS\npara comenzar a rastrear tus casos.';

  @override
  String get addFirstCase => 'Agregar Primer Caso';

  @override
  String get addCase => 'Agregar Caso';

  @override
  String get receiptNumber => 'Número de Recibo';

  @override
  String get receiptHint => 'ej: EAC9999103403';

  @override
  String get receiptHelper =>
      'Se encuentra en tu Aviso de Acción del USCIS (I-797)';

  @override
  String get nicknameOptional => 'Apodo (opcional)';

  @override
  String get nicknameHint => 'ej: Mi Green Card, Visa de Cónyuge';

  @override
  String get trackThisCase => 'Rastrear Este Caso';

  @override
  String get caseAddedSuccess => 'Caso agregado exitosamente';

  @override
  String get receiptRequired => 'El número de recibo es obligatorio';

  @override
  String get receiptTooShort => 'Número de recibo muy corto';

  @override
  String get receiptInvalidPrefix =>
      'Debe comenzar con 3 letras (ej: IOE, EAC, WAC)';

  @override
  String get receiptInvalidSuffix =>
      'Los dígitos deben seguir el prefijo de 3 letras';

  @override
  String get receiptInfoBanner =>
      'Tu número de recibo está en el Aviso de Acción del USCIS (Formulario I-797). Comienza con 3 letras seguidas de 10 dígitos.';

  @override
  String get currentStatus => 'Estado Actual';

  @override
  String get caseHistory => 'Historial del Caso';

  @override
  String caseHistoryCount(int count) {
    return '$count eventos';
  }

  @override
  String get statusUnavailable => 'Estado no disponible';

  @override
  String get statusUnavailableSubtitle =>
      'No se pudo obtener el estado del USCIS. Intenta actualizar.';

  @override
  String get editNickname => 'Editar Apodo';

  @override
  String get removeCase => 'Eliminar Caso';

  @override
  String removeCaseConfirm(String receipt) {
    return '¿Eliminar $receipt de tus casos rastreados? Esta acción no se puede deshacer.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get remove => 'Eliminar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get nickname => 'Apodo';

  @override
  String get nicknamePlaceholder => 'ej: Mi Green Card';

  @override
  String get failedToUpdate => 'Error al actualizar';

  @override
  String get failedToRemove => 'Error al eliminar';

  @override
  String get failedToAdd => 'Error al agregar el caso. Intenta de nuevo.';

  @override
  String get alreadyTracked => 'Este caso ya está en tu lista.';

  @override
  String get invalidReceiptFormat => 'Formato de número de recibo inválido.';

  @override
  String get caseNotFound => 'Caso no encontrado en el sistema USCIS.';

  @override
  String get profile => 'Perfil';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutConfirm => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get language => 'Idioma';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get errorOccurred => 'Ocurrió un error. Intenta de nuevo.';

  @override
  String get connectionError =>
      'No se pudo conectar al servidor. Verifica tu conexión.';

  @override
  String get sessionExpired => 'Sesión expirada. Inicia sesión de nuevo.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageSpanish => 'Español';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Predeterminado del sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';
}
