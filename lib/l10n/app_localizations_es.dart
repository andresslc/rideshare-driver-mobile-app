// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get app_name => 'Paseos épicos';

  @override
  String get bank_account => 'Cuenta bancaria';

  @override
  String get select_language => 'Seleccionar idioma';

  @override
  String get english => 'Inglés';

  @override
  String get language_already_selected => 'Este idioma ya está seleccionado';

  @override
  String get view_profile => 'Ver perfil';

  @override
  String get my_cards => 'Mis Tarjetas';

  @override
  String get ok => 'DE ACUERDO';

  @override
  String get spanish => 'Español';

  @override
  String get cancel => 'Cancelar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get end_ride => 'Finalizar viaje';

  @override
  String get field_required => 'Este campo es obligatorio';

  @override
  String get private => 'Privada';

  @override
  String get ssn_field_valid =>
      'El número de seguro social debe tener exactamente 9 dígitos';

  @override
  String name_min_length(int min) {
    return 'El nombre debe tener al menos $min caracteres';
  }

  @override
  String get todays_rides => 'Viajes hoy';

  @override
  String get your_car => 'Tu coche';

  @override
  String get ratings => 'Calificaciones';

  @override
  String get unabletosubmitfeedback => 'No se pudo enviar la opinión';

  @override
  String get rideDetails => 'Detalles del viaje';

  @override
  String get noSpecialRequest => 'Sin solicitud especial';

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get addReviewHere => 'Agrega tu opinión aquí...';

  @override
  String get submitReview => 'Enviar opinión';

  @override
  String get carpool => 'Compartidos';

  @override
  String get nocompleteridesfound => 'No se encontraron viajes completados';

  @override
  String get pleaseselectrating => 'Por favor selecciona una calificación';

  @override
  String get noPassengerfound => 'No se encontraron pasajeros';

  @override
  String get noCarpoolridesfound => 'No se encontraron viajes compartidos';

  @override
  String get seatBooked => 'Número de asientos reservados';

  @override
  String get cancellationReason => 'Razón de cancelación';

  @override
  String get noReasonProvided => 'No se proporcionó ninguna razón';

  @override
  String get review => 'Revisión';

  @override
  String get your_complete_finished_trip =>
      'Tus viajes finalizados aparecerán aquí';

  @override
  String get your_have_not_cancelled => 'No has cancelado ningún viaje';

  @override
  String get no_rides_cancelled_by_driver =>
      'Ningún viaje cancelado por el conductor';

  @override
  String get carpool_text => 'Aún no hay viajes compartidos';

  @override
  String get transactions => 'Aún no hay transacciones';

  @override
  String get type_amount => 'Escribe el monto';

  @override
  String get bank_acc => 'Agrega una cuenta para retiros rápidos';

  @override
  String get notification_center => 'Ya estás al día';

  @override
  String get complete_rides_rating =>
      'Completa los recorridos para empezar a obtener una calificación';

  @override
  String get invite_friends =>
      'Tu historial de referencias aparecerá aquí una vez que empieces a invitar';

  @override
  String get account_status_complete_title => 'Complete su envío';

  @override
  String get account_status_complete_message =>
      'Ha ingresado cierta información, pero su cuenta aún no está bajo revisión.\nEnvíe sus datos para continuar con el proceso de verificación.';

  @override
  String get profile_review_notice =>
      '*Una vez que se actualiza la información del vehículo o del documento, el perfil del conductor pasará a un estado de revisión. ';

  @override
  String profileYearTooOld(Object year) {
    return 'El año no puede ser anterior a $year';
  }

  @override
  String get profileYearFuture => 'El año no puede ser en el futuro.';

  @override
  String get no_changes => 'No hay cambios para actualizar.';

  @override
  String get name_no_numbers => 'El nombre no puede contener números';

  @override
  String get name_invalid_characters =>
      'El nombre contiene caracteres no válidos';

  @override
  String get next => 'Siguiente';

  @override
  String get skip => 'Saltar';

  @override
  String get back => 'Atrás';

  @override
  String get done => 'Hecho';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Borrar';

  @override
  String get delete_notification => 'Eliminar notificación';

  @override
  String get delete_notification_confirmation =>
      '¿Está seguro de que desea eliminar esta notificación?';

  @override
  String get delete_all_notifications => 'Eliminar todas las notificaciones';

  @override
  String get delete_all_notifications_confirmation =>
      '¿Está seguro de que desea eliminar todas las notificaciones?';

  @override
  String get notification_deleted_success =>
      'La notificación se eliminó correctamente.';

  @override
  String get notifications_deleted_success =>
      'Todas las notificaciones se eliminaron correctamente.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get and => 'y';

  @override
  String get search => 'Buscar';

  @override
  String get onboarding_title_1 => 'Reserve un viaje fácilmente';

  @override
  String get onboarding_subtitle_1 =>
      'Encuentre y reserve viajes cerca de usted en segundos.';

  @override
  String get onboarding_title_2 => 'Rastree a su conductor';

  @override
  String get onboarding_subtitle_2 =>
      'Seguimiento en tiempo real desde la recogida hasta la devolución.';

  @override
  String get onboarding_title_3 => 'Seguro y protegido';

  @override
  String get onboarding_subtitle_3 =>
      'Su seguridad es nuestra principal prioridad.';

  @override
  String get get_started => 'Empezar';

  @override
  String get start_ride => 'Iniciar viaje';

  @override
  String get welcome_back => '¡Bienvenido!';

  @override
  String get login_subtitle =>
      'Por favor ingrese su número de teléfono para iniciar sesión.';

  @override
  String get phone_number => 'Número de teléfono';

  @override
  String get enter_phone_number => 'Introduce tu número de teléfono';

  @override
  String get add_phone_number => 'Agregar número de teléfono';

  @override
  String get continue_with_phone => 'Continuar con el número de teléfono';

  @override
  String get no_account_prompt => '¿No tienes una cuenta? ';

  @override
  String get phone_required => 'Se requiere número de teléfono';

  @override
  String get phone_invalid => 'El número de teléfono debe ser válido.';

  @override
  String get verification => 'Verificación';

  @override
  String otp_subtitle(Object number) {
    return 'Ingrese el código OTP enviado a $number';
  }

  @override
  String get enter_otp => 'Ingrese la OTP';

  @override
  String get accept => 'Aceptar';

  @override
  String get view_detail => 'Ver detalles';

  @override
  String get otp_required => 'Ingrese la OTP para continuar';

  @override
  String get did_not_receive_code => '¿No recibiste el código?';

  @override
  String get resend_now => 'Reenviar ahora';

  @override
  String get number_verified => 'Número verificado';

  @override
  String get number_verified_message =>
      '¡Tu número de teléfono ha sido verificado exitosamente!';

  @override
  String get verify => 'Verificar';

  @override
  String get accepted => 'Aceptado';

  @override
  String get account_under_review_title => 'Cuenta en revisión';

  @override
  String get account_under_review_message =>
      'Su cuenta de conductor se encuentra actualmente bajo revisión. ';

  @override
  String get account_review_notify_message =>
      'Se le notificará una vez completada la revisión.';

  @override
  String get updates_visit_label => 'Para actualizaciones, visita:';

  @override
  String get account_not_approved_title => 'Cuenta no aprobada';

  @override
  String get subscription_status => 'Estado de suscripción';

  @override
  String get account_not_approved_message =>
      'Su cuenta de conductor no fue aprobada en este momento. ';

  @override
  String get reapply_at_label => 'Volver a aplicar en:';

  @override
  String get forgot_password => 'Has olvidado tu contraseña';

  @override
  String get forgot_password_subtitle =>
      'Ingrese su dirección de correo electrónico para restablecer su contraseña.';

  @override
  String get back_to_login => 'Volver a iniciar sesión';

  @override
  String get create_profile => 'Crear perfil';

  @override
  String get signup_subtitle => 'Por favor ingresa tus datos para registrarte.';

  @override
  String get sign_up => 'Inscribirse';

  @override
  String get already_have_account => '¿Ya tienes una cuenta? ';

  @override
  String get by_registering => 'Al registrarte aceptas nuestra';

  @override
  String get full_name => 'Nombre completo';

  @override
  String get enter_full_name => 'Introduce tu nombre completo';

  @override
  String get full_name_required => 'Se requiere nombre completo';

  @override
  String get email_address => 'Dirección  de correo electrónico';

  @override
  String get in_app => 'En la aplicación';

  @override
  String get enter_email => 'Introduce tu dirección de correo electrónico';

  @override
  String get upload_profile_picture => 'Subir foto de perfil';

  @override
  String get optional => '(Opcional)';

  @override
  String get my_profile => 'Mi perfil';

  @override
  String get edit_profile => 'Editar perfil';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get total_time => 'Tiempo total';

  @override
  String get total_distance => 'Distancia total';

  @override
  String get min => 'mín';

  @override
  String get sec => 'seg.';

  @override
  String get hour => 'hora';

  @override
  String get passenger => 'Pasajera';

  @override
  String get detail => 'Detalle';

  @override
  String get avg_time => 'Tiempo promedio';

  @override
  String get total_amount => 'Cantidad total';

  @override
  String get pickup_location => 'Ubicación de recogida';

  @override
  String get stop => 'Parada';

  @override
  String get dropoff_location => 'Lugar de destino';

  @override
  String get completed => 'Terminado';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get subtitle_logout =>
      '¿Está seguro de que desea cerrar sesión en su cuenta?';

  @override
  String get where_to => '¿Adonde?';

  @override
  String get logoutDialogTitle => 'Confirmar cierre de sesión';

  @override
  String get profileEditSuccess => 'Editar perfil correctamente';

  @override
  String get profile_update_subtitle =>
      'El perfil se ha actualizado correctamente';

  @override
  String get location => 'Ubicación';

  @override
  String get current_location => 'Ubicación actual';

  @override
  String get pickup_details => 'Detalles de recogida';

  @override
  String get special_request => 'Solicitud especial';

  @override
  String get set_pickup_location => 'Establecer ubicación de recogida';

  @override
  String get set_dropoff_location => 'Establecer ubicación de entrega';

  @override
  String get confirm_location => 'Confirmar Ubicación';

  @override
  String get luxury => 'Lujo';

  @override
  String get economy => 'Economía';

  @override
  String get premium => 'De primera calidad';

  @override
  String get select_ride => 'Seleccionar viaje';

  @override
  String get estimated_time => 'Tiempo estimado';

  @override
  String get estimated_fare => 'Tarifa estimada';

  @override
  String get finding_driver => 'Buscando a su conductor...';

  @override
  String get driver_on_the_way => 'El conductor está en camino.';

  @override
  String get arrived => 'Llegó';

  @override
  String get driver_arrived => 'El conductor ha llegado';

  @override
  String get ride_started => 'Viaje iniciado';

  @override
  String get ride_in_progress => '¡Paseo en progreso!';

  @override
  String get reached_destination => '¡Has llegado a tu destino!';

  @override
  String get reached_pickup_point => '¡Has llegado al punto de recogida!';

  @override
  String get ride_completed => 'Viaje completado';

  @override
  String get session_expired => 'Sesión caducada';

  @override
  String get cancel_ride => 'Cancelar viaje';

  @override
  String get cancel_carpool => 'Cancelar carpool';

  @override
  String get cancel_ride_confirmation =>
      '¿Estás seguro de que deseas cancelar este viaje?';

  @override
  String get driver_profile => 'Perfil del conductor';

  @override
  String get call_driver => 'Llamar al conductor';

  @override
  String get chat_with_driver => 'Chatear con el conductor';

  @override
  String get payment_method => 'Método de pago';

  @override
  String get wallet => 'Billetera';

  @override
  String get add_payment_method => 'Agregar método de pago';

  @override
  String get add_card => 'Agregar tarjeta';

  @override
  String get card_number => 'Número de tarjeta';

  @override
  String get expiry_date => 'Fecha de vencimiento';

  @override
  String get cvv => 'CVV';

  @override
  String get card_holder_name => 'Nombre del titular de la tarjeta';

  @override
  String get add_account => 'Agregar cuenta';

  @override
  String get delete_account => 'Eliminar cuenta';

  @override
  String get ride_history => 'Historial de viajes';

  @override
  String get no_rides_found => 'No se encontraron viajes';

  @override
  String get rate_your_ride => 'Califica tu viaje';

  @override
  String get leave_feedback => 'Deja un comentario';

  @override
  String get add_tip => 'Agregar sugerencia';

  @override
  String get submit => 'Entregar';

  @override
  String get settings => 'Ajustes';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get privacy_policy => 'Política de Privacidad';

  @override
  String get terms_conditions => 'Términos y condiciones';

  @override
  String get continue_label => 'Continuar';

  @override
  String get service_region_title => 'Fuera de la región de servicio';

  @override
  String service_region_message(Object regionName) {
    return 'Ahora mismo no estás en $regionName. Por favor, elige una ubicación dentro de $regionName para continuar.';
  }

  @override
  String get service_region_logout => 'Cerrar sesión';

  @override
  String get no_vehicle_types_available =>
      'No hay tipos de vehículo disponibles.';

  @override
  String get support => 'Apoyo';

  @override
  String get help_center => 'Centro de ayuda';

  @override
  String get something_went_wrong => 'Algo salió mal. ';

  @override
  String get no_internet => 'Sin conexión a internet';

  @override
  String get try_again => 'Intentar otra vez';

  @override
  String get home => 'Hogar';

  @override
  String get ride_request => 'Solicitud de viaje';

  @override
  String get ride_request_unavailable =>
      'Esta solicitud de viaje ya no está disponible.';

  @override
  String get ride_request_taken_toast => 'Otro conductor tomó ese viaje.';

  @override
  String get ride_request_expired_toast => 'Esa solicitud de viaje venció.';

  @override
  String ride_request_dispatch_radius(Object radius, Object unit) {
    return 'a $radius $unit';
  }

  @override
  String get ride_request_offline_toast =>
      'Estás sin conexión en este momento. Vuelve a conectarte para ver las solicitudes de viaje.';

  @override
  String get ride_request_refreshing_queue_label =>
      'Actualizando la cola en vivo';

  @override
  String get ride_request_syncing_queue_label => 'Sincronizando la cola';

  @override
  String ride_request_updated_label(Object timeAgo) {
    return 'Actualizado $timeAgo';
  }

  @override
  String ride_request_live_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# solicitudes en vivo',
      one: '# solicitud en vivo',
      zero: 'La cola está vacía',
    );
    return '$_temp0';
  }

  @override
  String get ride_request_live_subtitle =>
      'Las solicitudes más recientes permanecen fijadas arriba para que la última esté siempre primero.';

  @override
  String get ride_request_ready_subtitle =>
      'Estás en línea y listo. Actualizaremos esta cola cada pocos segundos.';

  @override
  String get ride_request_go_online_subtitle =>
      'Ponte en línea desde el panel para empezar a recibir solicitudes de viaje.';

  @override
  String get ride_request_status_live_sync => 'Sincronización en vivo';

  @override
  String get ride_request_status_newest_first => 'Más recientes primero';

  @override
  String get ride_request_driver_online => 'El conductor está en línea';

  @override
  String get ride_request_driver_offline => 'El conductor está desconectado';

  @override
  String get ride_request_empty_title_online =>
      'No hay solicitudes pendientes ahora mismo';

  @override
  String get ride_request_empty_title_offline =>
      'Estás sin conexión en este momento';

  @override
  String get ride_request_empty_subtitle_online =>
      'Desliza para refrescar o mantén esta pantalla abierta. Las nuevas solicitudes aparecerán aquí automáticamente.';

  @override
  String get ride_request_empty_subtitle_offline =>
      'Regresa al panel y actívate en línea para empezar a recibir nuevas solicitudes.';

  @override
  String get date => 'Fecha';

  @override
  String get on => 'EN';

  @override
  String get wait_timer => 'Temporizador de espera';

  @override
  String get off => 'NO';

  @override
  String get hello => 'Hola';

  @override
  String get account_name => 'Información de la cuenta';

  @override
  String get type => 'Tipo';

  @override
  String get status => 'Estado';

  @override
  String get amount => 'Cantidad';

  @override
  String get available_balance => 'Saldo disponible';

  @override
  String get no_transactions_found => 'No se encontró ninguna transacción';

  @override
  String get withdraw_funds => 'Retirar fondos';

  @override
  String get total_earnings => 'Ganancias totales';

  @override
  String get enter_amount => 'Ingrese el monto';

  @override
  String get language => 'Idioma';

  @override
  String get saved_locations => 'Ubicaciones guardadas';

  @override
  String get add_location => 'Agregar ubicación';

  @override
  String get office => 'Oficina';

  @override
  String get work => 'Trabajar';

  @override
  String get gym => 'Gimnasia';

  @override
  String get transactionHistory => 'Historial de transacciones';

  @override
  String get all => 'Todo';

  @override
  String get paid => 'Pagado';

  @override
  String get withdrawn => 'Retirado';

  @override
  String get location_permission_title => 'Permiso de ubicación';

  @override
  String get permission_denied_mesg =>
      'Esta app necesita tu ubicación para mostrar viajes cercanos y ofrecer servicios precisos de recogida y destino. Por favor concede el permiso de ubicación para continuar.';

  @override
  String get location_permission_required_title =>
      'Permiso de ubicación requerido';

  @override
  String get permanently_denied_mesg =>
      'El permiso de ubicación ha sido denegado permanentemente. Actívalo en la configuración del dispositivo para usar funciones basadas en ubicación.';

  @override
  String get location_services_disabled_title =>
      'Servicios de ubicación deshabilitados';

  @override
  String get location_services_disabled_mesg =>
      'Los servicios de ubicación están deshabilitados en tu dispositivo. Actívalos en la configuración para continuar.';

  @override
  String get ride_location_required_title =>
      'Activa el GPS para continuar el viaje';

  @override
  String get ride_location_required_message =>
      'Los servicios de ubicación deben permanecer activos durante un viaje en curso. Vuelve a activar el GPS para seguir usando la app y completar el viaje.';

  @override
  String get failed_to_request => 'Error al solicitar el permiso de ubicación';

  @override
  String get error_occurred =>
      'Ocurrió un error. Por favor intenta nuevamente.';

  @override
  String get open_settings => 'Configuración';

  @override
  String get withdrawal_now => 'retirar';

  @override
  String get themePreferences => 'Preferencias de tema';

  @override
  String get themeAutomatic => 'Automático (Modo Día y Noche)';

  @override
  String get themeAutomaticSubtitle =>
      'Tema claro durante el día y oscuro por la noche.';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeDarkSubtitle => 'Usar siempre modo oscuro';

  @override
  String get themeLight => 'Luz';

  @override
  String get themeLightSubtitle => 'Usar siempre modo claro';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get customer_reviews => 'Comentarios del cliente';

  @override
  String get reviews => 'Reseñas';

  @override
  String get cancelling => 'Cancelando...';

  @override
  String get see_less => 'Ver menos';

  @override
  String get see_more => 'Ver más';

  @override
  String get id => 'ID';

  @override
  String get invite_drawer => 'Invitar amigos';

  @override
  String get start_chat_fallback => 'Aún no hay mensajes nuevos';

  @override
  String get copy_link => 'Copiar enlace';

  @override
  String get your_ride_has_been => 'Tu viaje ha finalizado con éxito';

  @override
  String get whenStartRide => '¿Cuándo comenzarás este viaje?';

  @override
  String get chooseStartTime =>
      'Elige una hora específica para comenzar el viaje.';

  @override
  String get invitation_link => 'Enlace de invitación';

  @override
  String get rideStartTimeSeats => 'Hora de inicio del viaje y asientos';

  @override
  String star_count(Object star, Object count) {
    return '$star  ($count)';
  }

  @override
  String get search_address => 'Buscar dirección';

  @override
  String get we_couldnot_found =>
      'No pudimos encontrar ninguna dirección coincidente';

  @override
  String get use_this_address => 'Usar esta dirección';

  @override
  String get language_updated_title => '¡Idioma actualizado!';

  @override
  String get under_review_subtitle =>
      'Actualizar estos datos hará que su cuenta vuelva a estar en revisión. No podrá aceptar viajes hasta que su solicitud sea aprobada nuevamente. ¿Desea continuar?';

  @override
  String get passenger_detail => 'Detalle del pasajero';

  @override
  String get carpool_ride => 'Viaje';

  @override
  String get enter_last_name => 'Ingrese su apellido';

  @override
  String get enter_first_name => 'Ingrese su nombre';

  @override
  String get first_name => 'Nombre de pila';

  @override
  String get last_name => 'Apellido';

  @override
  String get enter_street => 'Ingrese la calle';

  @override
  String get street => 'Calle';

  @override
  String get enter_city => 'Ingrese la ciudad';

  @override
  String get city => 'Ciudad';

  @override
  String get enter_state => 'Ingrese el estado';

  @override
  String get state => 'Estado';

  @override
  String get going_back_under_review =>
      'Si regresas, estarás bajo revisión. ¿Estás seguro de que quieres regresar? Puedes actualizar estos datos si lo deseas.';

  @override
  String get language_updated_message =>
      'Your language has been updated successfully.';

  @override
  String get dashboard => 'Panel';

  @override
  String get invite_friend => 'invitar amigos';

  @override
  String get driverAccountNotCreatedWeb =>
      'Tu cuenta de conductor aún no ha sido creada. Regístrate primero en el sitio web.';

  @override
  String get driverAccountNotFound => 'Cuenta de conductor no encontrada';

  @override
  String get attach_bank_account => 'Adjunte su cuenta bancaria';

  @override
  String get debit => 'Débito';

  @override
  String get viewPassenger => 'Ver pasajeros';

  @override
  String get credit => 'Crédito';

  @override
  String get no_rides => 'No hay viajes disponibles';

  @override
  String get by_user => 'Por usuario';

  @override
  String get by_driver => 'Por conductor';

  @override
  String get no_bank_accounts_found => 'No se encontraron cuentas bancarias';

  @override
  String get attached_bank_accounts => 'Cuentas bancarias adjuntas';

  @override
  String get select_bank => 'Seleccionar banco';

  @override
  String get platform_fee_deducted =>
      'Se deducirá una tarifa de plataforma del 3% del monto de su retiro.';

  @override
  String get delete_bank_account => 'Eliminar cuenta bancaria';

  @override
  String bank_delete_confirmation(Object bankTitle, Object last4) {
    return '¿Está seguro de que desea eliminar $bankTitle que termina en $last4?';
  }

  @override
  String get bank_attach_failed => 'No se pudo adjuntar la cuenta bancaria.';

  @override
  String get bank_account_attached_success =>
      'Cuenta bancaria adjunta correctamente.';

  @override
  String get bank_account_deleted_success =>
      'Cuenta bancaria eliminada exitosamente.';

  @override
  String get attach_bank_account_description =>
      'Agregue una cuenta bancaria de EE. UU. ';

  @override
  String get account_holder_name => 'Nombre del titular de la cuenta';

  @override
  String get account_holder_name_required =>
      'El nombre del titular de la cuenta es obligatorio.';

  @override
  String get routing_number => 'Número de ruta';

  @override
  String get routing_number_required => 'Se requiere número de ruta';

  @override
  String get routing_number_must_be_9_digits =>
      'El número de ruta debe tener 9 dígitos';

  @override
  String get account_number => 'Número de cuenta';

  @override
  String get account_number_required => 'Se requiere el número de cuenta';

  @override
  String get account_number_must_be_4_to_17_digits =>
      'El número de cuenta debe tener entre 4 y 17 dígitos';

  @override
  String get country_us => 'País (EE.UU.)';

  @override
  String get country_required => 'Se requiere país';

  @override
  String get currency_usd => 'Moneda (USD)';

  @override
  String get currency_required => 'Se requiere moneda';

  @override
  String get account_holder_type => 'Tipo de titular de la cuenta';

  @override
  String get individual => 'Individual';

  @override
  String get company => 'Compañía';

  @override
  String get add_bank_account => 'Vincular a cuenta bancaria';

  @override
  String get driver_onboarding_title =>
      'Los conductores se registran a través del portal web.';

  @override
  String get driver_onboarding_message =>
      'Si tu número ya está registrado, recibirás un OTP para continuar.';

  @override
  String get driver_onboarding_visit_label =>
      'El registro está disponible en línea';

  @override
  String get click_here => 'Haga clic aquí';

  @override
  String get account_approved_title => '¡Tu cuenta ha sido aprobada con éxito!';

  @override
  String get manu_year => 'Año de fabricación';

  @override
  String get account_approved_message =>
      'Para comenzar a usar los servicios, compra un plan de suscripción. Una vez que tu suscripción esté activa, podrás acceder a todas las funciones.';

  @override
  String get subscription_note =>
      'Nota: Para comprar una suscripción, visita el sitio web usando el siguiente enlace:';

  @override
  String get subscription_status_title => 'Estado de suscripción';

  @override
  String get profileRegistrationMustBeUnique =>
      'El número de registro debe ser único';

  @override
  String subscription_status_message(Object status) {
    return 'Tu suscripción $status, por favor renuévala.';
  }

  @override
  String get subscription_renew_note =>
      'Para renovar tu suscripción, visita el sitio web a continuación:';

  @override
  String get profileVinMustBeUnique => 'El VIN debe ser único';

  @override
  String get delete_account_otp_prefix => 'Enviaremos un código de 6 dígitos a';

  @override
  String get delete_account_data_warning =>
      'Tus datos se eliminarán permanentemente de nuestra base de datos.';

  @override
  String get send_otp => 'Enviar OTP';

  @override
  String get valid_amount => 'Por favor ingresa un monto válido';

  @override
  String get amount_must_be_greater_than_0 => 'El monto debe ser mayor que 0';

  @override
  String get insufficient_balance => 'Saldo insuficiente';

  @override
  String get max_2_decimal_places_allowed => 'Se permiten máximo 2 decimales';

  @override
  String get profileMyProfile => 'Mi perfil';

  @override
  String get profilePersonalInformation => 'Información personal';

  @override
  String get profileVehicleDetails => 'Detalles del vehículo';

  @override
  String get profileDrivingLicense => 'Licencia de conducir';

  @override
  String get profileVehicleRegistration => 'Registro del vehículo';

  @override
  String get profileInsuranceInformation => 'Información del seguro';

  @override
  String get profileUnableToLoad => 'No se pudo cargar el perfil.';

  @override
  String get profileRetry => 'Reintentar';

  @override
  String get profileChooseFromGallery => 'Elegir de la galería';

  @override
  String get profileTakePhoto => 'Tomar foto';

  @override
  String get profileEditPersonalInformation => 'Editar información personal';

  @override
  String get profileChangeProfilePicture => 'Cambiar foto de perfil';

  @override
  String get profilePictureRequired => 'La foto de perfil es obligatoria';

  @override
  String get profileFullName => 'Nombre completo';

  @override
  String get rideRequestsWaiting => 'Hay solicitudes de viaje esperando';

  @override
  String get driverOnlineActive =>
      'Estás en línea y listo para recibir el próximo viaje';

  @override
  String get driverGoOnline =>
      'Ponte en línea para empezar a recibir solicitudes de viaje';

  @override
  String get vehicleMake => 'Marca';

  @override
  String get vehicleModel => 'Modelo';

  @override
  String get vehicleRegistration => 'Matrícula';

  @override
  String get vehicleType => 'Tipo de Vehículo';

  @override
  String get camera_permission_title => 'Permiso de cámara';

  @override
  String get camera_permission_subtitle =>
      'Se requiere permiso de cámara para continuar';

  @override
  String get profileEnterFullName => 'Ingresa el nombre completo';

  @override
  String get profileEmailAddress => 'Correo electrónico';

  @override
  String get profileEnterEmailAddress => 'Ingresa el correo electrónico';

  @override
  String get profileAddress => 'Dirección';

  @override
  String get profileEnterAddress => 'Ingresa la dirección';

  @override
  String get profileStreet => 'Calle';

  @override
  String get profileEnterStreet => 'Ingresa la dirección de la calle';

  @override
  String get profileCity => 'Ciudad';

  @override
  String get profileEnterCity => 'Ingresa la ciudad';

  @override
  String get profileState => 'Estado';

  @override
  String get profileEnterState => 'Ingresa el estado';

  @override
  String get profilePhoneNumber => 'Número de teléfono';

  @override
  String get profilePhoneNumberHint => 'Número de teléfono';

  @override
  String get profileUpdate => 'Actualizar';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado correctamente';

  @override
  String get profileEditVehicleDetails => 'Editar detalles del vehículo';

  @override
  String get profileVehicleMake => 'Hacer';

  @override
  String get profileVehicleModel => 'Modelo';

  @override
  String get profileVehicleColor => 'Color del vehículo';

  @override
  String get profileYear => 'Año de fabricación';

  @override
  String get profileVin => 'Número de identificación del vehículo';

  @override
  String get profileLicensePlate => 'Número de placa';

  @override
  String get profileRegistrationNumber => 'Número de registro';

  @override
  String get profileRegionOfRegistration => 'Estado/Región de Registro';

  @override
  String get profileRegistrationExpiry => 'Fecha de vencimiento del registro';

  @override
  String get profileVehicleType => 'Tipo de vehículo';

  @override
  String get profileVehicleUpdatedSuccessfully =>
      'Se han enviado los datos del vehículo para su aprobación';

  @override
  String get unable_to_get => 'No se pudo obtener tu ubicación actual';

  @override
  String get chat_no_messages_yet => 'Aún no hay mensajes nuevos';

  @override
  String get profileDataNotLoaded =>
      'Los datos del perfil aún no están cargados.';

  @override
  String get profileNoChanges => 'No hay cambios para actualizar.';

  @override
  String get profileFieldRequired => 'Este campo es obligatorio';

  @override
  String get profileVinInvalidLength =>
      'El VIN debe tener exactamente 17 caracteres';

  @override
  String get profileVinInvalidFormat =>
      'Ingresa un VIN válido (letras y números, excepto I, O y Q)';

  @override
  String get profileNumberPlateInvalid =>
      'La placa debe tener de 1 a 7 letras o números en mayúscula';

  @override
  String get profileRegistrationNumberInvalid =>
      'El número de registro debe tener de 1 a 8 letras o números en mayúscula';

  @override
  String get profileEnterValidYear => 'Introduzca un año válido';

  @override
  String get profileYearRange => 'El año debe estar entre 1900 y 2100';

  @override
  String get profileEditDriverLicense => 'Editar licencia de conducir';

  @override
  String get profileLicenseUpdatedSuccessfully =>
      'Licencia actualizada correctamente';

  @override
  String get profileEditInsurance => 'Editar información del seguro';

  @override
  String get profileInsuranceUpdatedSuccessfully =>
      'Seguro actualizado correctamente';

  @override
  String get profileEditVehicleRegistration => 'Editar registro del vehículo';

  @override
  String get profileVehicleRegistrationUpdatedSuccessfully =>
      'Registro del vehículo actualizado correctamente';

  @override
  String get profileUploadFrontImage => 'Subir imagen frontal';

  @override
  String get profileUploadBackImage => 'Subir imagen posterior';

  @override
  String get profileUploadDocumentHint =>
      'Subir documento (JPG/PNG hasta 20MB)';

  @override
  String get profileExpiryDate => 'Fecha de vencimiento';

  @override
  String get profileLicenseNumber => 'Número de licencia';

  @override
  String get profileEnterLicenseNumber => 'Ingresa el número de licencia';

  @override
  String get profileFrontImageRequired => 'La imagen frontal es obligatoria.';

  @override
  String get profileBackImageRequired => 'La imagen posterior es obligatoria.';

  @override
  String get profileUnableToPrepareFrontBack =>
      'No se pudieron preparar las imágenes frontal y posterior. Vuelve a seleccionarlas e inténtalo de nuevo.';

  @override
  String get profileUnableToPrepareFront =>
      'No se pudo preparar la imagen frontal. Vuelve a seleccionarla e inténtalo de nuevo.';

  @override
  String get profileUnableToPrepareInsurance =>
      'No se pudo preparar la imagen del seguro. Vuelve a seleccionarla e inténtalo.';

  @override
  String profileImageTooLarge(Object size) {
    return 'El tamaño de la imagen supera los $size MB. Selecciona un archivo más pequeño.';
  }

  @override
  String get profileImageInvalidType =>
      'Tipo de archivo no válido. Solo se permiten JPG y PNG.';

  @override
  String get image_selection_failed =>
      'La selección de la imagen falló. Inténtalo de nuevo.';

  @override
  String map_load_error(Object error) {
    return 'Error al cargar el mapa: $error';
  }

  @override
  String get no_reviews_found => 'Aún no hay reseñas disponibles.';

  @override
  String get profileNoInternetConnection =>
      'Sin conexión a internet. Verifica tu red e intenta nuevamente.';

  @override
  String get give_rating => 'Dar calificación al usuario';

  @override
  String get subtitle_dialgue =>
      '¡Tu informe ha sido enviado! Investigaremos el problema.';

  @override
  String get report_submitted => 'Informe enviado';

  @override
  String get recent_ride => 'Viaje recientes';

  @override
  String get rate_passenger => 'Califica a tu pasajero';

  @override
  String get your_rating => 'Tu calificación';

  @override
  String get hint_description => 'Descripción';

  @override
  String get reason => 'Razón';

  @override
  String get report_user => 'Reportar usuario';

  @override
  String get chat_message_hint => 'Mensaje';

  @override
  String get chat_block => 'Bloquear';

  @override
  String get chat_report => 'Reportar';

  @override
  String get report_reason_unprofessional => 'Comportamiento poco profesional';

  @override
  String get report_reason_poor_communication => 'Mala comunicación';

  @override
  String get report_reason_fake_account => 'Cuenta falsa o suplantación';

  @override
  String get report_reason_harassment => 'Acoso o intimidación';

  @override
  String get report_reason_abuse => 'Abuso o mala conducta';

  @override
  String get report_reason_violation_policies => 'Incumplimiento de políticas';

  @override
  String get block_user => 'Bloquear usuario';

  @override
  String get block_user_confirmation =>
      '¿Estás seguro de que quieres bloquear a este usuario?';

  @override
  String get don_t_block => 'No bloquear';

  @override
  String get block_now => 'Bloquear ahora';

  @override
  String get we_appreciate_issue =>
      'Agradecemos tus comentarios. Proporciona detalles y investigaremos el problema.';

  @override
  String get your_passenger_feedback =>
      'Tus comentarios nos ayudan a mantener una comunidad segura y respetuosa para todos.';

  @override
  String get miles => 'millas';

  @override
  String get selectStartTime => 'Seleccionar hora de inicio';

  @override
  String get ride_date_yesterday => 'Ayer';

  @override
  String get selectTime => 'Inicia en';

  @override
  String get select_time_valid =>
      'Por favor, seleccione una hora antes de continuar.';

  @override
  String get ride_date_today => 'Hoy';

  @override
  String get selectFutureTime => 'Por favor selecciona una hora futura';

  @override
  String get howManyPassengers =>
      '¿Cuántos pasajeros puedes llevar en este viaje?';

  @override
  String get numberPassengers => 'Número de pasajeros';

  @override
  String get vehicleSeatLimit =>
      '* Solo puedes seleccionar asientos según la capacidad de tu vehículo registrado.';

  @override
  String get continueSearch => 'Continuar para buscar';

  @override
  String get minimumSeatRequired => 'El asiento debe ser mínimo 1';

  @override
  String get start_time => 'Hora de inicio del viaje';

  @override
  String get ride_time => 'Tiempo del viaje';

  @override
  String get start_time_within_hour =>
      'Selecciona una hora de inicio dentro de 1 hora a partir de ahora.';

  @override
  String get unable_to_create_carpool_route =>
      'No se pudo crear la ruta de viaje compartido.';

  @override
  String get ride_progress => 'Progreso del viaje';

  @override
  String ride_progress_stop(int index) {
    return 'Parada $index';
  }

  @override
  String get ride_progress_no_route => 'Sin datos de ruta';

  @override
  String get start_time_label => 'Hora de inicio';

  @override
  String get available_seats => 'Asientos disponibles';

  @override
  String get total_distance_label => 'Distancia total';

  @override
  String get accept_one_passenger_hint =>
      'Acepta al menos un pasajero para iniciar el viaje.';

  @override
  String arrive_at_stop(int index) {
    return 'Llegar a la parada $index';
  }

  @override
  String get drop_off_passengers => 'Dejar pasajeros';

  @override
  String get ssn => 'Número de seguro social';

  @override
  String get enter_destination => 'Ingresar destino';

  @override
  String get select_both_locations => 'Selecciona ambas ubicaciones';

  @override
  String get rate_all_passengers_or_skip =>
      'Califica a todos los pasajeros o toca Omitir.';

  @override
  String get give_rating_users => 'Dar calificación a los usuarios';

  @override
  String get submitting => 'Enviando...';

  @override
  String get rate_your_passengers => 'Califica a tus pasajeros';

  @override
  String get no_passengers_to_rate => 'No hay pasajeros para calificar.';

  @override
  String passenger_number(int index) {
    return 'Pasajero $index';
  }

  @override
  String get selected_location_label => 'Ubicación seleccionada';

  @override
  String get search_place_hint => 'Busca un lugar...';

  @override
  String get no_new_notifications => 'No hay nuevas notificaciones';

  @override
  String get missing_carpool_id => 'Falta ID de viaje compartido';

  @override
  String get unable_to_go_online_title => 'No se puede estar en línea';

  @override
  String get fetching_location => 'Obteniendo ubicación...';

  @override
  String get current_location_available => 'Ubicación actual disponible';

  @override
  String get unable_to_fetch_location => 'No se pudo obtener la ubicaciÃ³n';

  @override
  String get carpool_promo_subtitle =>
      'Gana más dinero compartiendo tu ruta con los pasajeros que se dirigen hacia ti';

  @override
  String get carpool_start_button => 'Iniciar viaje compartido';

  @override
  String get carpool_online_before_start =>
      'Activa en lÃ­nea antes de iniciar un viaje compartido';

  @override
  String get normal_online_before_start =>
      'Conéctate antes de comenzar el viaje';

  @override
  String get unable_to_submit => 'No se pudo enviar comentarios';

  @override
  String get link_copied => 'Enlace copiado';

  @override
  String get stars => 'estrellas';

  @override
  String get unable_to_submit_rating => 'No se pudo enviar la calificación';

  @override
  String get please_select_rating => 'Por favor seleccione calificación';

  @override
  String get add_stops_title => 'Agregar paradas para viaje compartido';

  @override
  String get ride_start_time =>
      'Hora de inicio de la atracción y disponibilidad de asientos';

  @override
  String get list_of_request => 'Lista de solicitudes';

  @override
  String get search_carpool_ride => 'Buscar viaje compartido';

  @override
  String get add_stops_subtitle =>
      'Agrega paradas en tu ruta para aceptar pasajeros de carpool facilmente.';

  @override
  String stop_title(int index) {
    return 'Parada $index';
  }

  @override
  String get starting_point_suffix => ' (Punto de inicio)';

  @override
  String get final_destination_suffix => ' (Destino final)';

  @override
  String get tap_to_select_location => 'Toca para seleccionar ubicación';

  @override
  String get add_stops => 'Agregar paradas';

  @override
  String get save_stops_continue => 'Guardar paradas y continuar';

  @override
  String get add_stop_warning =>
      'Agrega al menos una parada antes de continuar.';

  @override
  String get carpool_requests_title => 'Solicitudes de carpool';

  @override
  String carpool_requests_counts(int pending, int accepted) {
    return 'Pendientes: $pending | Aceptadas: $accepted';
  }

  @override
  String get carpool_missing_id =>
      'Falta el ID de carpool. Regresa y crea la ruta nuevamente.';

  @override
  String get carpool_pending_requests => 'Solicitudes pendientes';

  @override
  String get carpool_no_pending => 'No hay solicitudes pendientes ahora.';

  @override
  String get carpool_accepted_passengers => 'Pasajeros aceptados';

  @override
  String get carpool_no_accepted => 'Aún no hay pasajeros aceptados.';

  @override
  String get carpool_continue_progress => 'Continuar al progreso del viaje';

  @override
  String get carpool_back_to_search => 'Volver a la busqueda';

  @override
  String get no_of_passengers => 'N.º de pasajeros';

  @override
  String get reject => 'Rechazar';

  @override
  String get otp_verified => 'OTP verificado';

  @override
  String get booking_id_missing =>
      'Falta el ID de reserva para esta solicitud.';

  @override
  String request_action_failed(Object action) {
    return 'No se pudo $action la solicitud.';
  }

  @override
  String get request_accept_success => 'Pasajero aceptado correctamente.';

  @override
  String get request_reject_success => 'Pasajero rechazado correctamente.';

  @override
  String get search_carpool_title => 'Buscando solicitudes de carpool';

  @override
  String get starting_point => 'Punto de inicio';

  @override
  String get destination => 'Destino';

  @override
  String stop_label(int index) {
    return 'Parada $index';
  }

  @override
  String get ride_start_time_label => 'Hora de inicio del viaje';

  @override
  String get available_seats_label => 'Asientos disponibles';

  @override
  String requests_found(int count) {
    return '$count solicitudes encontradas';
  }

  @override
  String view_requests(int count) {
    return 'Ver solicitudes ($count)';
  }

  @override
  String get go_to_ride_progress => 'Ir al progreso del viaje';

  @override
  String get unable_cancel_carpool => 'No se pudo cancelar el carpool.';

  @override
  String get pickup_verification_title => 'Verificación de recogida';

  @override
  String get enter_otp_to_verify =>
      'Ingresa el código OTP para verificar tu viaje';

  @override
  String otp_length_error(int length) {
    return 'Ingresa un OTP válido de $length dígitos.';
  }

  @override
  String get otp_invalid_message =>
      'OTP inválido. Verifica e inténtalo nuevamente.';

  @override
  String get today_label => 'Hoy';

  @override
  String get no_incoming => 'No hay viajes entrantes en este momento';

  @override
  String get yesterday_label => 'Ayer';

  @override
  String get passenger_pick_success => 'Pasajero recogido correctamente.';

  @override
  String get passenger_pick_failed => 'No se pudo recoger al pasajero.';

  @override
  String get ride_end_success => 'Viaje finalizado correctamente.';

  @override
  String get ride_end_failed => 'No se pudo finalizar el viaje.';

  @override
  String get passenger_removed_success => 'Pasajero eliminado correctamente.';

  @override
  String get passenger_removed_failed => 'No se pudo eliminar al pasajero.';

  @override
  String get removing => 'Eliminando...';

  @override
  String get remove_passenger => 'Eliminar pasajero';

  @override
  String get passenger_dropped => 'Pasajero bajado';

  @override
  String get dropping => 'Bajando...';

  @override
  String get picking => 'Recogiendo...';

  @override
  String get drop_passenger => 'Bajar pasajero';

  @override
  String get pick_passenger => 'Recoger pasajero';

  @override
  String get success_profile_approved_title => 'Perfil aprobado';

  @override
  String get success_profile_approved_message =>
      'Tu perfil ha sido aprobado correctamente.';

  @override
  String get success_account_deleted_title => '¡Cuenta eliminada!';

  @override
  String get success_account_deleted_message =>
      'Tu cuenta ha sido eliminada correctamente.';

  @override
  String get success_funds_added_title => 'Fondos agregados';

  @override
  String get success_funds_added_message =>
      'Tus fondos se han agregado correctamente.';

  @override
  String get success_feedback_title => '¡Agradecemos tus comentarios!';

  @override
  String get success_feedback_message => 'Tu reseña ha sido enviada.';

  @override
  String get invalid_otp => 'Código OTP inválido. Inténtalo de nuevo.';

  @override
  String get verify_delete_account => 'Verificar y eliminar cuenta';

  @override
  String get feedback_subtitle =>
      'Tu opinión nos ayuda a mantener una comunidad segura y respetuosa para todos.';

  @override
  String get no_internet_title => 'Sin conexión a Internet';

  @override
  String get no_internet_subtitle =>
      'Por favor, comprueba tu configuración de red e inténtalo de nuevo para seguir usando la aplicación.';

  @override
  String get slow_connection_title => 'Conexión demasiado lenta';

  @override
  String get slow_connection_subtitle =>
      'Tu conexión a internet es demasiado lenta para usar la aplicación en este momento. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get slow_connection_banner =>
      'Conexión inestable. Algunas acciones pueden tardar.';

  @override
  String get retry => 'Reintentar';

  @override
  String get notification_fallback_title => 'Notificación';

  @override
  String get end_ride_confirmation =>
      '¿Estás seguro de que quieres finalizar este viaje?';

  @override
  String get drop_passenger_confirmation =>
      '¿Estás seguro de que quieres dejar a este pasajero?';

  @override
  String get cancel_ride_question => '¿Por qué cancelas este viaje?';

  @override
  String get reason_harassment => 'El pasajero me está acosando';

  @override
  String get reason_not_responding => 'El pasajero no responde';

  @override
  String get reason_asked_to_cancel => 'El pasajero me pidió que cancelara';

  @override
  String get reason_unsafe_location => 'Ubicación de recogida insegura';

  @override
  String get reason_vehicle_issue => 'Problema del vehículo';

  @override
  String get reason_other => 'Otro';

  @override
  String get navigate_in_google_maps => 'Iniciar Navegación';

  @override
  String get unable_to_open_google_maps => 'No se pudo iniciar la navegación';

  @override
  String get warning => 'Advertencia';

  @override
  String get recommend_google_maps =>
      'Toca para iniciar la navegación paso a paso';

  @override
  String get minimum_5_characters_required =>
      'Se requieren al menos 5 caracteres';

  @override
  String get address_cannot_be_only_numbers =>
      'La dirección no puede contener solo números';

  @override
  String get address_invalid => 'Dirección no válida';

  @override
  String get confirm_stop => 'Confirmar Parada';

  @override
  String get confirm_pickup => 'Confirmar Recogida';

  @override
  String get confirm_dropoff => 'Confirmar Entrega';

  @override
  String get search_stop => 'Buscar una Parada...';

  @override
  String get search_pickup => 'Buscar un lugar de recogida...';

  @override
  String get search_dropoff => 'Buscar un lugar de entrega...';

  @override
  String get navigate_to_destination => 'Iniciar Navegación';

  @override
  String get navigation_route_calculating => 'Calculando ruta...';

  @override
  String get navigation_arrived => '¡Has llegado a tu destino!';

  @override
  String get navigation_route_failed =>
      'Error al calcular la ruta. Inténtalo de nuevo.';

  @override
  String get only_florida_addresses_supported =>
      'Solo se admiten direcciones de Florida (FL)';

  @override
  String get regular_balance => 'Saldo Principal';

  @override
  String get rewarded_balance => 'Saldo de Recompensa';

  @override
  String get regular => 'Regular';

  @override
  String get rewarded => 'Recompensa';

  @override
  String get referral_drawer => 'Mi código de conductor';

  @override
  String get referral_title => 'Mi código de conductor';

  @override
  String referral_explainer(Object bonus) {
    return 'Muestra este código a los nuevos pasajeros para reclamar un bono de $bonus de recompensa.';
  }

  @override
  String get referral_paused =>
      'Los códigos de referido están pausados por ahora.';

  @override
  String get referral_history => 'Historial de referidos';

  @override
  String get referral_rider_fallback => 'Pasajero';

  @override
  String get referral_status_saved => 'Esperando su primer viaje';

  @override
  String get referral_status_applied => 'Viaje en curso';

  @override
  String get referral_status_completed => 'Bono ganado';

  @override
  String get referral_status_voided => 'Viaje cancelado, sin bono';

  @override
  String get referral_copy_code => 'Copiar código';

  @override
  String get referral_code_copied => 'Código copiado';

  @override
  String get referral_share => 'Compartir código';

  @override
  String referral_share_message(Object code, Object discount) {
    return 'Viaja con nosotros y obtén $discount de descuento en tu primer viaje. Usa mi código $code al registrarte.';
  }

  @override
  String get referral_stat_saved => 'Guardaron tu código';

  @override
  String get referral_stat_applied => 'Viaje en curso';

  @override
  String get referral_stat_completed => 'Completados';

  @override
  String get referral_stat_earned => 'Total ganado';

  @override
  String get referral_stat_voided => 'Cancelados';

  @override
  String get transaction_referral_bonus => 'Bono por referido';

  @override
  String get transaction_reward => 'Recompensa';

  @override
  String get address_search_failed =>
      'No se pudo buscar esta dirección. Puedes volver a intentarlo o escribirla manualmente.';

  @override
  String get address_search_outside_region =>
      'Elige una dirección dentro del área de servicio.';

  @override
  String get address_search_retry => 'Intentar de nuevo';

  @override
  String get address_search_unavailable =>
      'La búsqueda de direcciones no está disponible. Ingresa la dirección manualmente.';

  @override
  String get address_search_incomplete =>
      'No se pudo confirmar esta dirección. Ingresa la dirección manualmente.';
}
