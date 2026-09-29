// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get certificateDetails => 'Detalhes do certificado';

  @override
  String get issuer => 'Emissor';

  @override
  String get issueDate => 'Data de emissão';

  @override
  String get description => 'Descrição';

  @override
  String get files => 'Arquivos';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get openFile => 'Abrir arquivo';

  @override
  String get attachFiles => 'Anexar arquivos';

  @override
  String get deleteCertificateTitle => 'Excluir certificado?';

  @override
  String get deleteCertificateMessage =>
      'Isso também excluirá os arquivos armazenados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get newCertificate => 'Novo certificado';

  @override
  String get editCertificate => 'Editar certificado';

  @override
  String get title => 'Título';

  @override
  String selectFiles(Object count) {
    return 'Selecionar arquivos ($count/5)';
  }

  @override
  String get createCertificate => 'Criar certificado';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get onlyAllowedFiles =>
      'Apenas JPG, PNG e PDF de até 1 MB são permitidos.';

  @override
  String get selectAtLeastOneFile => 'Selecione pelo menos um arquivo.';

  @override
  String get enterTitle => 'Informe um título';

  @override
  String get enterIssuer => 'Informe um emissor';

  @override
  String get unableToLoadCertificate =>
      'Não foi possível carregar o certificado.';

  @override
  String get certificateDeleted => 'Certificado excluído.';

  @override
  String get fileAttached => 'Arquivo anexado.';
}
