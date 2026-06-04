/* SPDX-License-Identifier: Apache-2.0 */

/* Hand-written config.h for the vendored libnfc build.
 *
 * Replaces the autoconf-generated config.h. Only the defines actually
 * referenced by the compiled subset of libnfc sources are set here
 * (see the Makefile for the source list).
 *
 * - Only the PN532 I2C driver is enabled (e.g. PN532 HATs on a
 *   Raspberry Pi, connstring "pn532_i2c:/dev/i2c-1").
 * - ENVVARS enables LIBNFC_DEFAULT_DEVICE / LIBNFC_LOG_LEVEL etc.
 * - CONFFILES is off: no /etc/nfc on embedded targets.
 * - LOG enables libnfc's stderr logging, controlled at runtime via
 *   LIBNFC_LOG_LEVEL (off by default).
 */

#ifndef LIBNFC_EX_CONFIG_H
#define LIBNFC_EX_CONFIG_H

#define PACKAGE_NAME "libnfc"
#define PACKAGE_VERSION "1.8.0"
#define PACKAGE_STRING "libnfc 1.8.0"

#define DRIVER_PN532_I2C_ENABLED 1

#define ENVVARS 1
#define LOG 1

#endif /* LIBNFC_EX_CONFIG_H */
