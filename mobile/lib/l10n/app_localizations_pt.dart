// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Rastreador de Casos USCIS';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get signInSubtitle => 'Entre para rastrear seus casos no USCIS';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get noAccount => 'Não tem uma conta?';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get emailRequired => 'E-mail é obrigatório';

  @override
  String get emailInvalid => 'Digite um e-mail válido';

  @override
  String get passwordRequired => 'Senha é obrigatória';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createAccountSubtitle => 'Comece a rastrear seus casos no USCIS';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get passwordMinLength => 'Mínimo de 8 caracteres';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get fullNameRequired => 'Nome completo é obrigatório';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta?';

  @override
  String get myCases => 'Meus Casos';

  @override
  String hello(String name) {
    return 'Olá, $name';
  }

  @override
  String get noCasesYet => 'Nenhum caso ainda';

  @override
  String get noCasesSubtitle =>
      'Adicione seus números de recibo do USCIS\npara começar a rastrear seus casos.';

  @override
  String get addFirstCase => 'Adicionar Primeiro Caso';

  @override
  String get addCase => 'Adicionar Caso';

  @override
  String get receiptNumber => 'Número de Recibo';

  @override
  String get receiptHint => 'ex: EAC9999103403';

  @override
  String get receiptHelper =>
      'Encontrado no seu Aviso de Ação do USCIS (I-797)';

  @override
  String get nicknameOptional => 'Apelido (opcional)';

  @override
  String get nicknameHint => 'ex: Meu Green Card, Visto de Cônjuge';

  @override
  String get trackThisCase => 'Rastrear Este Caso';

  @override
  String get caseAddedSuccess => 'Caso adicionado com sucesso';

  @override
  String get receiptRequired => 'Número de recibo é obrigatório';

  @override
  String get receiptTooShort => 'Número de recibo muito curto';

  @override
  String get receiptInvalidPrefix =>
      'Deve começar com 3 letras (ex: IOE, EAC, WAC)';

  @override
  String get receiptInvalidSuffix =>
      'Dígitos devem seguir o prefixo de 3 letras';

  @override
  String get receiptInfoBanner =>
      'Seu número de recibo está no Aviso de Ação do USCIS (Formulário I-797). Começa com 3 letras seguidas de 10 dígitos.';

  @override
  String get currentStatus => 'Status Atual';

  @override
  String get caseHistory => 'Histórico do Caso';

  @override
  String caseHistoryCount(int count) {
    return '$count eventos';
  }

  @override
  String get statusUnavailable => 'Status indisponível';

  @override
  String get statusUnavailableSubtitle =>
      'Não foi possível obter o status do USCIS. Tente atualizar.';

  @override
  String get editNickname => 'Editar Apelido';

  @override
  String get removeCase => 'Remover Caso';

  @override
  String removeCaseConfirm(String receipt) {
    return 'Remover $receipt dos seus casos rastreados? Esta ação não pode ser desfeita.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get remove => 'Remover';

  @override
  String get refresh => 'Atualizar';

  @override
  String get nickname => 'Apelido';

  @override
  String get nicknamePlaceholder => 'ex: Meu Green Card';

  @override
  String get failedToUpdate => 'Falha ao atualizar';

  @override
  String get failedToRemove => 'Falha ao remover';

  @override
  String get failedToAdd => 'Falha ao adicionar caso. Tente novamente.';

  @override
  String get alreadyTracked => 'Este caso já está na sua lista.';

  @override
  String get invalidReceiptFormat => 'Formato de número de recibo inválido.';

  @override
  String get caseNotFound => 'Caso não encontrado no sistema USCIS.';

  @override
  String get profile => 'Perfil';

  @override
  String get about => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutConfirm => 'Tem certeza que deseja sair?';

  @override
  String get language => 'Idioma';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get errorOccurred => 'Ocorreu um erro. Tente novamente.';

  @override
  String get connectionError =>
      'Não foi possível conectar ao servidor. Verifique sua conexão.';

  @override
  String get sessionExpired => 'Sessão expirada. Faça login novamente.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageSpanish => 'Español';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeSystem => 'Padrão do sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';
}
